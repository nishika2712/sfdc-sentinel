public class MissingFLSRule implements IAuditRule {

    public List<AuditFinding> runCheck() {
        List<AuditFinding> findings = new List<AuditFinding>();

        // Step 1: Get all custom fields on key objects (start with Account, Opportunity, Contact for v1 scope)
        List<String> objectsToCheck = new List<String>{ 'Account', 'Opportunity', 'Contact' };

        for (String objApiName : objectsToCheck) {
            Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objApiName);
            if (sObjType == null) continue;

            Map<String, Schema.SObjectField> fieldMap = sObjType.getDescribe().fields.getMap();

            for (String fieldApiName : fieldMap.keySet()) {
                // Only check custom fields (they end in __c)
                if (!fieldApiName.endsWith('__c')) continue;

                String fullFieldName = objApiName + '.' + fieldApiName;

                // Step 2: Check FieldPermissions for any grant on this field
                Integer grantCount = [
                    SELECT COUNT()
                    FROM FieldPermissions
                    WHERE Field = :fullFieldName
                    AND (PermissionsRead = true OR PermissionsEdit = true)
                ];

                if (grantCount == 0) {
                    findings.add(new AuditFinding(
                        'Missing Field Level Security',
                        'High',
                        'Security',
                        objApiName,
                        fieldApiName,
                        'Field ' + fullFieldName + ' has no Field-Level Security granted on any Profile or Permission Set.',
                        'Add this field to at least one Permission Set or Profile with appropriate Read/Edit access.'
                    ));
                }
            }
        }

        return findings;
    }
}
