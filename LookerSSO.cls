//
// Looker Embed SSO 
// SFDC Apex Class
// https://docs.looker.com/reference/embedding/sso-embed
//
// Cleaned up and expanded version of this class
// https://github.com/ppksathish/Embed-SSO-Looker-UI-in-Salesforce/blob/master/LookerEmbedController.cls
//

public class LookerSSO {
    
	String lookerSecret;
	String lookerHost;

    // Default models SSO users will have access to 
	List<String> defaultModels = new List<String>{
		'my_model'
	};

    // Default permissions for SSO user
    // Full permission list here: https://docs.looker.com/reference/embedding/sso-embed
	List<String> defaultPermissions = new List<String>{
		'access_data', 'see_looks', 'see_user_dashboards','see_drill_overlay'
	};

	/**
	* LookerSSO
	* Generate dashboard and look links with embedded SSO details
	*
	* @param  host Looker host without protocol, ie. tophat.looker.com
	* @param  lookerSecret Looker embed secret generated through the Looker admin console
	*/
    public LookerSSO(String host, String lookerSecret) {
		this.lookerHost = host;
		this.lookerSecret = lookerSecret;
	}

	/**
	* Generate an SSO link to a Looker dashboard
	*
	* @param  dashboardId Id of the Looker dashboard as a string
	* @param  email The email address of the SSO user. Used as externalUserID
	* @param  firstName User first name
	* @param  lastName User last name
	*/
	public String createDashboardUrl(String dashboardId, String email, String firstName, String lastName) {
		String embedUrl = '/embed/dashboards/' + dashboardId;
		String url = this.createUrl(embedUrl, email, firstName, lastName);
		return url;
	}

	/**
	* Generate an SSO link to a Looker Look
	*
	* @param  lookId Id of the Looker Look as a string
	* @param  email The email address of the SSO user used as externalUserID
	* @param  firstName User first name
	* @param  lastName User last name
	*/
	public String createLookUrl(String lookId, String email, String firstName, String lastName) {
		String embedUrl = '/embed/looks/' + lookId;
		String url = this.createUrl(embedUrl, email, firstName, lastName);
		return url;
	}

    private String createURL(String embedUrl, String email, String first, String last) {
	    //List of input variables 
        String host = this.lookerHost;
        String externalUserID = json.serialize(email);
        String firstName = json.serialize(first);
        String lastName = json.serialize(last);
        String permissions = json.serialize(this.defaultPermissions);
        String models = json.serialize(this.defaultModels);
        String groupID = json.serialize(new list<Integer>{7});
        String sessionLength = '3600';
        String forceLogoutLogin = 'false';
        String nonce = json.serialize(LookerSSO.generateRandomString(16));
        DateTime currentTime = DateTime.now();
        String uNIXTime = String.valueOf(currentTime.getTime() / 1000);
        String extenalGroupID = json.serialize('none');
        String userAttribute = LookerSSO.jsonInnerString('organization_code', '%');
        Object userAttrribute = json.deserializeUntyped(userAttribute);
        userAttribute = json.serialize(userAttrribute);
        String embedPath =  '/login/embed/'+ EncodingUtil.urlEncode(embedUrl, 'UTF-8');
        String accessFiltter = '{}';
        Object userAttrribute1 = json.deserializeUntyped(accessFiltter);
        accessFiltter = json.serialize(userAttrribute1);

        String signatureURL = '';
        signatureURL += host + '\n';
        signatureURL += embedPath + '\n';
        signatureURL += nonce + '\n';
        signatureURL += uNIXTime + '\n';
        signatureURL += sessionLength + '\n';
        signatureURL += externalUserID + '\n';
        signatureURL += permissions + '\n';
        signatureURL += models + '\n';
        signatureURL += groupID + '\n';
        signatureURL += extenalGroupID + '\n';
        signatureURL += userAttribute + '\n';
        signatureURL += accessFiltter;
		
        String finalSignature = this.generateSignature(signatureURL);
		
		//URL parameters
        String parameter = 'nonce='+EncodingUtil.urlEncode(nonce, 'UTF-8') + 
                              '&time='+EncodingUtil.urlEncode(uNIXTime, 'UTF-8') + 
                              '&session_length='+EncodingUtil.urlEncode(String.valueOf(sessionLength), 'UTF-8') + 
                              '&external_user_id='+EncodingUtil.urlEncode(externalUserID, 'UTF-8') +
                              '&permissions='+EncodingUtil.urlEncode(permissions, 'UTF-8') +
                              '&models='+EncodingUtil.urlEncode(models, 'UTF-8') +
                              '&signature='+finalSignature +
                              '&first_name='+EncodingUtil.urlEncode(firstName, 'UTF-8') +
                              '&last_name='+EncodingUtil.urlEncode(lastName, 'UTF-8') +
                              '&group_ids='+EncodingUtil.urlEncode(groupID, 'UTF-8') +
                              '&external_group_id='+EncodingUtil.urlEncode(extenalGroupID, 'UTF-8') +
                              '&user_attributes='+EncodingUtil.urlEncode(userAttribute, 'UTF-8') +
                              '&force_logout_login='+EncodingUtil.urlEncode(forceLogoutLogin, 'UTF-8') +
                              '&access_filters='+EncodingUtil.urlEncode(accessFiltter, 'UTF-8') ;
							  
        return 'https://'+host + embedPath + '?' + parameter;
    }

    public String generateSignature(String inputValue) {        
        String signature = LookerSSO.generateHMACSignature(inputValue, this.lookerSecret);
        return signature;
    }
	
    public static  String generateHMACSignature(String inputValue, String secretKey) {
        String algorithmName = 'HmacSHA1';
        Blob blobHMACData = Crypto.generateMac(algorithmName, Blob.valueOf(inputValue), Blob.valueOf(secretKey));
        return EncodingUtil.base64Encode(blobHMACData);
    }

    public static  String jsonInnerString(String key, String value) {
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        jsonGen.writeStringField(key, value);
        jsonGen.writeEndObject();
        return jsonGen.getAsString();
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }	
}
