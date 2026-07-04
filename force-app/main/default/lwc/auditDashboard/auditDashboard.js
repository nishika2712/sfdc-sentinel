import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe } from 'lightning/empApi';
import startScan from '@salesforce/apex/AuditDashboardController.startScan';
import getFindings from '@salesforce/apex/AuditDashboardController.getFindings';

const COLUMNS = [
    { label: 'Rule', fieldName: 'Rule_Name__c' },
    { label: 'Severity', fieldName: 'Severity__c' },
    { label: 'Category', fieldName: 'Category__c' },
    { label: 'Object', fieldName: 'Object_API_Name__c' },
    { label: 'Field/Component', fieldName: 'Field_Or_Component_Name__c' },
    { label: 'Issue', fieldName: 'Issue_Description__c', wrapText: true },
    {
        type: 'button',
        typeAttributes: {
            label: 'Remediate',
            name: 'remediate',
            variant: 'brand-outline',
            disabled: { fieldName: 'isNotFLS' }
        }
    }
];

export default class AuditDashboard extends LightningElement {
    columns = COLUMNS;
    findings = [];
    isScanning = false;
    scanStarted = false;
    progressLabel = '';
    progressPercent = 0;
    subscription = null;
    wiredFindingsResult;
    showFlow = false;

    @wire(getFindings)
    wiredFindings(result) {
        this.wiredFindingsResult = result;
        if (result.data) {
            this.findings = result.data.map(f => ({
                ...f,
                isNotFLS: f.Rule_Name__c !== 'Missing Field Level Security'
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
                refreshApex(this.wiredFindingsResult);
            } else {
                this.progressLabel = 'Running: ' + currentRule + ' (' + completed + '/' + total + ')';
            }
        }).then((response) => {
            this.subscription = response;
        });
    }

    handleStartScan() {
        this.scanStarted = true;
        this.isScanning = true;
        this.showFlow = false;
        this.progressPercent = 0;
        this.progressLabel = 'Starting scan...';

        startScan()
            .catch((error) => {
                this.isScanning = false;
                this.progressLabel = 'Scan failed: ' + (error.body ? error.body.message : error.message);
            });
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
        return this.findings && this.findings.length > 0;
    }

    get showNoFindings() {
        return !this.isScanning && this.scanStarted && this.findings.length === 0;
    }

    get scanButtonLabel() {
        return this.isScanning ? 'Scanning...' : 'Run New Scan';
    }
}
