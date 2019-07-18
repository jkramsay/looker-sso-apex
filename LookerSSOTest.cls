
@isTest
private class LookerSSOTest {
    
    @isTest
    static void testLookerSSOUrl() {

        String dashboardId = '15401';
        String lookId = '490343';
        String email = 'my_email@test.com';
        String firstName = 'UserFirst';
        String lastName = 'andLast';
        String host = 'subdomain.looker.com';
        String secretKey = 'my-looker-secret-key';
        
        LookerSSO looker = new LookerSSO(host, secretKey);

        String dashboardUrl = looker.createDashboardUrl(dashboardId, email, firstName, lastName);
        System.assertNotEquals(Null, dashboardUrl);
        System.assert(dashboardUrl.length() > 0);

        String lookUrl = looker.createLookUrl(lookId, email, firstName, lastName);
        System.assertNotEquals(Null, lookUrl);
        System.assert(lookUrl.length() > 0);
        
        String expectedUrl = 'https://' + host + '/login/embed/%2Fembed%2Flooks%2F' + lookId;
        System.assertEquals(expectedUrl, lookUrl.substring(0, 63));

        // Assert some parameters
        PageReference url = new PageReference(lookUrl);
        Map<String, String> params =  url.getParameters();

        System.assertEquals(14, params.size());
        System.assert(params.containsKey('nonce'));

        System.assert(params.containsKey('time'));
        System.assert(params.containsKey('session_length'));
        System.assert(params.containsKey('external_user_id'));
        System.assert(params.containsKey('permissions'));
        System.assert(params.containsKey('models'));
        System.assert(params.containsKey('signature'));
        System.assert(params.containsKey('first_name'));
        System.assert(params.containsKey('last_name'));
        System.assert(params.containsKey('group_ids'));
        System.assert(params.containsKey('external_group_id'));
        System.assert(params.containsKey('user_attributes'));
        System.assert(params.containsKey('force_logout_login'));
        System.assert(params.containsKey('access_filters'));
        System.assert(params.get('session_length') == '3600');
        System.assert(params.get('force_logout_login') == 'false');  
        System.assertEquals('"' + firstName + '"', params.get('first_name'));  
        System.assertEquals('"' + lastName + '"', params.get('last_name'));
        System.assertEquals('"' + email + '"', params.get('external_user_id'));        
    }
}

