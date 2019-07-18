# looker-sso-apex
SFDC Apex Class for Looker SSO Embed

Embed Looker dashboards and looks in Salesforce Visualforce or Lightning components. 
Class and test class for generating SSO urls from Looker.

Slight enhancement of:
https://github.com/ppksathish/Embed-SSO-Looker-UI-in-Salesforce/blob/master/LookerEmbedController.cls

Usage Example:

```
        String email = 'jkramsay@somedomain.com';
        String firstName = 'JK';
        String lastName = 'Ramsay';
        String host = 'subdomain.looker.com';
        String secretKey = 'my-secret-key';
        
        LookerSSO looker = new LookerSSO(host, secretKey);
        String lookUrl = looker.createLookUrl('MYLOOKID', email, firstName, lastName);
```
