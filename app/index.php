<?php
// try 
// {
//     $db = new PDO("sqlite:db/buttons.sqlite");
//     $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

//     // Create table
//     $query = 'CREATE TABLE IF NOT EXISTS buttons ' .
//              '(id integer PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, value BLOB NOT NULL)';

//     $db->exec($query);

//     // Insert records
//     $insert = "INSERT INTO buttons (name, value) 
//                 VALUES (:name, :value)";

//     $stmt = $db->prepare($insert);
//     $stmt->bindParam(':name', $name);
//     $stmt->bindParam(':value', $value);

//     $name = "test";
//     $value = 000;

//     $stmt->execute();

//     // Get record
//     $result = $db->query('SELECT * FROM buttons');

//     foreach ($result as $m) {
//         var_dump($m);
//     }

//     $db = null;
// }
// catch(PDOException $e)
// {
//     die($error);
// }

?>

<!doctype html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <title>OpenWRT Panel</title>
    <meta name="description" content="">
    <meta name="viewport" content="width=device-width">
    <!-- Place favicon.ico and apple-touch-icon.png in the root directory -->

    <!-- build:css({.tmp,app}) styles/main.css -->
    <link rel="stylesheet" href="styles/main.css">
    <!-- endbuild -->
  </head>
  <body ng-app="openwrtPanelApp">

    <div class="panelWrapper">
        <div id="panel">
            <!-- Add your site or application content here -->
            <div class="container" transition-view in-class="in" out-class="out"></div>
        </div>
    </div>

    <script src="bower_components/jquery/jquery.js"></script>
    <script src="bower_components/angular/angular.js"></script>

    <!-- build:js({.tmp,app}) scripts/scripts.js -->
    <script src="scripts/app.js"></script>
    <script src="scripts/directives.js"></script>
    <script src="scripts/controllers.js"></script>
    <!-- endbuild -->

    <!-- build:js scripts/plugins.js -->
    <script src="bower_components/foundation/js/foundation/foundation.js"></script>
    <!-- endbuild -->

    <!-- build:js scripts/modules.js -->
    <script src="bower_components/angular-resource/angular-resource.js"></script>
    <script src="bower_components/angular-cookies/angular-cookies.js"></script>
    <!-- endbuild -->
  </body>
</html>