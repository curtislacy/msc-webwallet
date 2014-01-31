function EditContactController( $scope, $http ) {

	var params = BTCUtils.getQueryStringArgs();
	if( params.addr && params.addr != 'sample_addr' )
	{
		$scope.address = params.addr;
		$scope.addressReadOnly = true;
		console.log( 'TODO: Actually look up values and populate name, etc.' );
	}
}
