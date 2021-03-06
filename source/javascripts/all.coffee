angular.module('MenuFlick', ['ngMobile', 'LocalStorageModule'])

  .config(['$routeProvider', ($routeProvider) ->
    $routeProvider
      .when('/', templateUrl: 'leaderboards.html', controller: 'LeaderBoardsCtrl')
      .when('/items/:itemid', templateUrl: 'item-detail.html', controller: 'ItemDetailCtrl')
      .when('/login', templateUrl: 'login.html', controller: 'LoginCtrl')
      .when('/sign-up', templateUrl: 'sign-up.html', controller: 'SignUpCtrl')
      .when('/submit-item', templateUrl: 'submit-item.html', controller: 'SubmitItemCtrl')
      .when('/profile', templateUrl: 'profile.html', controller: 'ProfileCtrl')
      .when('/profile/lists', templateUrl: 'profilelists.html', controller: 'ProfileListCtrl')
      .when('/settings', templateUrl: 'settings.html', controller: 'SettingsCtrl')
      .when('/test', templateUrl: 'test.html', controller: 'TestCtrl')
      .when('/404', templateUrl: '404.html')
      .otherwise(redirectTo: '/login')
  ])

  .controller("AppCtrl", ['$scope', '$rootScope', '$http', 'localStorageService', '$location', ($scope, $rootScope, $http, localStorageService, $location) ->
    authValue = localStorageService.get('authToken')
    userId = localStorageService.get('userId')
    if authValue == null
      $location.path('/login')
      $scope.$apply
    $scope.logout = ->
      localStorageService.clearAll()
      $location.path('/login')
      $scope.$apply

  ])

  .controller("LoginCtrl", ['$scope', '$http', 'localStorageService', '$location', ($scope, $http, localStorageService, $location) ->
    $scope.login = ->

      $http(
        method: 'POST',
        url: 'http://mfbackend.appspot.com/json/login',
        data: $.param(
          username: $scope.user.username
          password: $scope.user.password
        ),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}
      ).success((data, status, headers, config) ->
        if data.response == 1
          $location.path('/')
          localStorageService.add('authToken', data.auth_token)
          localStorageService.add('userId', data.user_dict.user_id)
          $scope.$apply
        else
          alert "you've entered the wrong info!"
      ).error (data, status, headers, config) ->
  ])
  
  .controller("SignUpCtrl", ['$scope', '$http', 'localStorageService', '$location', ($scope, $http, localStorageService, $location) ->
    $scope.signUp = ->
      $http(
        method: 'POST',
        url: 'http://mfbackend.appspot.com/json/signup',
        data: $.param(
          email: $scope.user.email
          username: $scope.user.username
          password: $scope.user.password
          passwordtwo: $scope.user.passwordtwo
        ),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}
      ).success((data, status, headers, config) ->
        if data.response == 1
          alert "Thank you for signing up! You can now sign in!"
          $location.path('/login')
          $scope.$apply
      ).error (data, status, headers, config) ->
  ])

  .controller("ProfileCtrl", ['$scope', '$http', 'localStorageService', '$location', ($scope, $http, localStorageService, $location) ->
  ])

  .controller("TestCtrl", ['$scope', '$http', 'localStorageService', '$location', ($scope, $http, localStorageService, $location) ->
    $scope.submitItem  = (rating) ->
      reviewUrl = 'http://mfbackend.appspot.com/json/reviewitem'
      $http(
        method: 'POST',
        url: reviewUrl,
        data: $.param(
          userid: '43001'
          authtoken: '3Ccjm92ePBJ1BkZMSinVzY'
          itemid: ''
          itemname: 'A Sammich'
          restaurantid: ''
          restaurantname: 'The Dumpster'
          rating: '1'
          latitude: '33.088388'
          longitude: '-117.252548'
        ),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}
      ).success((ratingData, status, headers, config) ->
        console.log ratingData
      ).error (data, status, headers, config) ->
  ])

  .controller("ItemDetailCtrl", ['$scope', '$routeParams', '$http', 'localStorageService', '$location', ($scope, $routeParams, $http, localStorageService, $location) ->
    $http(
      method: "GET"
      url: "http://mfbackend.appspot.com/json/getitem?itemid=" + $routeParams.itemid
    ).success((data, status, headers, config) ->
      $scope.item = data
    ).error (data, status, headers, config) ->
  ])

  .controller("LeaderBoardsCtrl", ['$scope', '$rootScope', '$http', 'localStorageService', ($scope, $rootScope, $http, localStorageService) ->
    authValue = localStorageService.get('authToken')
    userId = localStorageService.get('userId')
    $scope.getLocation = ->
      window.navigator.geolocation.getCurrentPosition (position) ->
        $scope.$apply ->
          $http(
            method: "GET"
            url: "http://mfbackend.appspot.com/json/items?latitude=" + position.coords.latitude + "&longitude=" + position.coords.longitude + "&radius=1000000"
          ).success((itemData, status, headers, config) ->
            $scope.items = itemData.items
            $scope.rateItem = (rating, itemid, itemRating, i) ->
              console.log itemid
              reviewUrl = 'http://mfbackend.appspot.com/json/reviewitem'
              $http(
                method: 'POST',
                url: reviewUrl,
                data: $.param(
                  userid: userId
                  authtoken: authValue
                  itemid: itemid
                  itemname: itemData.items.rating
                  restaurantid: $scope.items[i].restaurantid
                  restaurantname: $scope.items[i].restaurantname
                  rating: itemRating
                  latitude: position.coords.latitude
                  longitude: position.coords.longitude
                  userid: userId
                  authtoken: authValue
                  itemid: itemid
                  rating: rating
                ),
                headers: {'Content-Type': 'application/x-www-form-urlencoded'}
              ).success((ratingData, status, headers, config) ->
                console.log $scope.items[i].rating = ratingData.rating
              ).error (data, status, headers, config) ->
          ).error (data, status, headers, config) ->


  ])
