public class OrgHealthUtility {

    // Covered by test
    public static Integer getActiveUserCount() {
        return [SELECT COUNT() FROM User WHERE IsActive = true];
    }

    // Covered by test
    public static Integer getCustomObjectCount() {
        return [SELECT COUNT() FROM EntityDefinition WHERE IsCustomizable = true];
    }

    // NOT covered - complex logic left untested
    public static Map<String, Integer> getRecordCountsByObject(List<String> objectNames) {
        Map<String, Integer> counts = new Map<String, Integer>();
        for (String objName : objectNames) {
            try {
                Integer count = Database.countQuery('SELECT COUNT() FROM ' + objName);
                counts.put(objName, count);
            } catch (Exception e) {
                counts.put(objName, -1);
            }
        }
        return counts;
    }

    // NOT covered - reporting logic left untested
    public static String generateHealthSummary(Integer userCount, Integer objectCount) {
        String summary = 'Org Health Summary:\n';
        summary += 'Active Users: ' + userCount + '\n';
        summary += 'Custom Objects: ' + objectCount + '\n';

        if (userCount > 100) {
            summary += 'Status: Large org - recommend regular audits\n';
        } else if (userCount > 20) {
            summary += 'Status: Medium org - quarterly audits recommended\n';
        } else {
            summary += 'Status: Small org - annual audits sufficient\n';
        }
        return summary;
    }

    // NOT covered - validation logic left untested
    public static Boolean isOrgHealthy(Integer coveragePercent, Integer activeRules) {
        if (coveragePercent < 75) return false;
        if (activeRules == 0) return false;
        return true;
    }
}
