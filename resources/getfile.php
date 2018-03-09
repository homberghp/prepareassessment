<?php

session_start();
if (!isset($_SERVER['PHP_AUTH_USER'])) {
    header('WWW-Authenticate: Basic realm="SEBI Venlo Performance Assessment Correctors Work Bench"');
    header('HTTP/1.0 401 Unauthorized');
    echo 'You should authenticate yourselves';
    exit;
}

include_once 'settings.php';
include_once '/usr/local/prepareassessment/resources/setdb.php';
if (isSet($_REQUEST['path'])) {
    $path = $_REQUEST['path'];
    if (false === strpos($path, '../')) { // avoid tree traversal
        $filepath = realpath($path);
        if (file_exists($filepath)) {
            $mime_type = mime_content_type($filepath);
            $size = filesize($filepath);
            $fp = @fopen($filepath, 'r');
            if ($fp != false) {
                header("Content-type: $mime_type");
                header("Pragma: public");
                header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
                header("Content-Length: {$size}");
                header("Content-Disposition: inline; filename={$path}");
                fpassthru($fp);
            }
        }
    }
}
exit(0);
