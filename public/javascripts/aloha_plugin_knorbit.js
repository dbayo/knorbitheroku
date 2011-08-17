/**
* Create the Repositories object. Namespace for Repositories
* @hide
*/
if ( !GENTICS.Aloha.Repositories ) GENTICS.Aloha.Repositories = {};

/**
* register the plugin with unique name
*/
GENTICS.Aloha.Repositories.myRepository = new GENTICS.Aloha.Repository(‘com.knorbit.aloha.repositories.MyRepository‘);

/**
* Init method of the repository. Called from Aloha Core to initialize this repository
* @return void
* @hide
*/
GENTICS.Aloha.Repository.myRepository.init = function() {
	this.repositoryName = 'knorbit';
};

/**
* Searches a repository for object items matching queryString if none found returns null.
* The returned object items must be an array of Aloha.Repository.Object
*
* @property {String} queryString
* @property {array} objectTypeFilter OPTIONAL Object types that will be returned.
* @property {array} filter OPTIONAL Attributes that will be returned.
* @property {string} inFolderId OPTIONAL his is a predicate function that tests whether or not a candidate object is a child-object of the folder object identified by the given inFolderId (objectId).
* @property {string} inTreeId OPTIONAL This is a predicate function that tests whether or not a candidate object is a descendant-object of the folder object identified by the given inTreeId (objectId).
* @property {array} orderBy OPTIONAL ex. [{lastModificationDate:’DESC’, name:’ASC’}]
* @property {Integer} maxItems OPTIONAL number items to return as result
* @property {Integer} skipCount OPTIONAL This is tricky in a merged multi repository scenario
* @property {array} renditionFilter OPTIONAL Instead of termlist an array of kind or mimetype is expected. If null or array.length == 0 all renditions are returned. See http://docs.oasis-open.org/cmis/CMIS/v1.0/cd04/cmis-spec-v1.0.html#_Ref237323310 for renditionFilter
* @param {object} params object with properties
* @param {function} callback this method must be called with all result items
*/
GENTICS.Aloha.Repository.myRepository.query = function( params, callback ) {
// get items
	var items = [];
	jQuery.getJSON(‘/spaces.json‘, function(data) {
		$.each(data, function(i,item) {
			items.push (new GENTICS.Aloha.Repository.Folder({
				id: 2,
				repositoryId: 'com.knorbit.aloha.repositories.MyRepository',
				name: item.name,
				type: 'directory',
				parentId:'/www'
				}))
				})

			});
	callback.call( this, items);
};

/**
* Returns all children of a given motherId.
* @property {array} objectTypeFilter OPTIONAL Object types that will be returned.
* @property {array} filter OPTIONAL Attributes that will be returned.
* @property {string} inFolderId OPTIONAL his is a predicate function that tests whether or not a candidate object is a child-object of the folder object identified by the given inFolderId (objectId).
* @property {array} orderBy OPTIONAL ex. [{lastModificationDate:’DESC’, name:’ASC’}]
* @property {Integer} maxItems OPTIONAL number items to return as result
* @property {Integer} skipCount OPTIONAL This is tricky in a merged multi repository scenario
* @property {array} renditionFilter OPTIONAL Instead of termlist an array of kind or mimetype is expected. If null or array.length == 0 all renditions are returned. See http://docs.oasis-open.org/cmis/CMIS/v1.0/cd04/cmis-spec-v1.0.html#_Ref237323310 for renditionFilter
* @param {object} params object with properties
* @param {function} callback this method must be called with all result items
*/
GENTICS.Aloha.Repository.myRepository.getChildren = function( params, callback ) { 
    // get items
	var items = [];
	jQuery.getJSON(‘/spaces.json‘,function(data) {
		$.each(data, function(i,item) {
			items.push (new GENTICS.Aloha.Repository.Folder({
				id: 2,
				repositoryId: 'com.knorbit.aloha.repositories.MyRepository',
				name: item.name,
				type: 'directory',
				parentId:'/www'
				}))
				})

			});
	callback.call( this, items);
};
};

