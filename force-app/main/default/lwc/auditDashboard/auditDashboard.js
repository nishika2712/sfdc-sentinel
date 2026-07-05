import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe } from 'lightning/empApi';
import startScan from '@salesforce/apex/AuditDashboardController.startScan';
import getFindings from '@salesforce/apex/AuditDashboardController.getFindings';
import runAllTestsAsync from '@salesforce/apex/TestCoverageService.runAllTestsAsync';
import checkTestRunStatus from '@salesforce/apex/TestCoverageService.checkTestRunStatus';

const COLUMNS = [
    { label: 'Rule', fieldName: 'Rule_Name__c' },
    { label: 'Severity', fieldName: 'Severity__c' },
    { label: 'Category', fieldName: 'Category__c' },
    { label: 'Object', fieldName: 'Object_API_Name__c' },
    { label: 'Field/Component', fieldName: 'Field_Or_Component_Name__c' },
    { label: 'Issue', fieldName: 'Issue_Description__c', wrapText: true },
    {
        type: 'action',
        typeAttributes: {
            rowActions: { fieldName: 'rowActions' }
        }
    }
];

export default class AuditDashboard extends LightningElement {
    columns = COLUMNS;
    findings = [];
    isScanning = false;
    scanStarted = false;
    scanCompleted = false;
    progressLabel = '';
    progressPercent = 0;
    subscription = null;
    wiredFindingsResult;
    showFlow = false;
    isRunningTests = false;
    testStatusMessage = '';
    _testRunId = null;
    _testPollInterval = null;
    _pollInterval = null;
    _pollCount = 0;

    @wire(getFindings)
    wiredFindings(result) {
        this.wiredFindingsResult = result;
        if (result.data) {
            this.findings = result.data.map(f => ({
                ...f,
                rowActions: f.Rule_Name__c === 'Missing Field Level Security'
                    ? [{ label: 'Remediate', name: 'remediate' }]
                    : []
            }));
        }
    }

    connectedCallback() {
        this.subscribeToProgress();
    }

    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription);
        }
        this.clearPoll();
        this.clearTestPoll();
    }

    subscribeToProgress() {
        const channel = '/event/Audit_Progress__e';
        subscribe(channel, -1, (eventReceived) => {
            const payload = eventReceived.data.payload;
            const completed = payload.Rules_Completed__c;
            const total = payload.Total_Rules__c;
            const status = payload.Status__c;
            const currentRule = payload.Current_Rule_Name__c;

            this.progressPercent = total > 0 ? Math.round((completed / total) * 100) : 0;

            if (status === 'Completed') {
                this.progressLabel = 'Scan completed';
                this.isScanning = false;
                this.scanCompleted = true;
                this.clearPoll();
                refreshApex(this.wiredFindingsResult);
            } else {
                this.progressLabel = 'Running: ' + currentRule + ' (' + completed + '/' + total + ')';
            }
        }).then((response) => {
            this.subscription = response;
        });
    }

    startPollingFallback() {
        this._pollCount = 0;
        this._pollInterval = setInterval(() => {
            this._pollCount++;
            if (this.progressPercent < 90 && this.isScanning) {
                this.progressPercent = Math.min(90, this.progressPercent + 8);
                this.progressLabel = 'Scanning your org...';
            }
            if (this._pollCount > 30) {
                this.clearPoll();
                this.isScanning = false;
                this.scanCompleted = true;
                this.progressPercent = 100;
                this.progressLabel = 'Scan completed';
                refreshApex(this.wiredFindingsResult);
            }
        }, 1000);
    }

    clearPoll() {
        if (this._pollInterval) {
            clearInterval(this._pollInterval);
            this._pollInterval = null;
        }
    }

    clearTestPoll() {
        if (this._testPollInterval) {
            clearInterval(this._testPollInterval);
            this._testPollInterval = null;
        }
    }

    handleStartScan() {
        this.scanStarted = true;
        this.scanCompleted = false;
        this.isScanning = true;
        this.showFlow = false;
        this.progressPercent = 0;
        this.progressLabel = 'Starting scan...';
        this.clearPoll();

        startScan()
            .then(() => {
                this.startPollingFallback();
            })
            .catch((error) => {
                this.isScanning = false;
                this.clearPoll();
                this.progressLabel = 'Scan failed: ' + (error.body ? error.body.message : error.message);
            });
    }

    handleRunTests() {
        this.isRunningTests = true;
        this.testStatusMessage = 'Starting test run...';
        this.clearTestPoll();

        runAllTestsAsync()
            .then((testRunId) => {
                this._testRunId = testRunId;
                this.testStatusMessage = 'Tests running — this may take a few minutes.';
                this.pollTestRunStatus();
            })
            .catch((error) => {
                this.isRunningTests = false;
                this.testStatusMessage = 'Failed to start tests: ' + (error.body ? error.body.message : error.message);
            });
    }

    pollTestRunStatus() {
        this._testPollInterval = setInterval(() => {
            checkTestRunStatus({ testRunId: this._testRunId })
                .then((status) => {
                    this.testStatusMessage = 'Test run: ' + status;
                    if (status === 'Completed' || status === 'Failed' || status === 'ERROR') {
                        this.clearTestPoll();
                        this.isRunningTests = false;
                        this.testStatusMessage = status === 'Completed'
                            ? '✓ Tests complete — run a new scan to see updated coverage.'
                            : '⚠ Test run ' + status + '. Check Apex Jobs in Setup.';
                    }
                })
                .catch(() => {
                    this.clearTestPoll();
                    this.isRunningTests = false;
                    this.testStatusMessage = 'Could not check test status.';
                });
        }, 5000);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        if (actionName === 'remediate') {
            this.showFlow = true;
        }
    }

    handleFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            this.showFlow = false;
            refreshApex(this.wiredFindingsResult);
        }
    }

    get hasFindings() {
        return this.scanCompleted && this.findings && this.findings.length > 0;
    }

    get showNoFindings() {
        return this.scanCompleted && !this.isScanning && this.findings.length === 0;
    }

    get scanButtonLabel() {
        return this.isScanning ? 'Scanning...' : 'Run New Scan';
    }

    get testButtonLabel() {
        return this.isRunningTests ? 'Running Tests...' : 'Run Tests & Refresh Coverage';
    }
}
