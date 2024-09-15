<?php

class Connection
{
    private static $instance = NULL;
    private static $path = "pgsql:host=localhost;port=5432;dbname=metrics";
    private static $user = "metrics_user";
    private static $pass = "DB_PASSWORD";

    private function __construct()
    {
        self::$instance = new PDO(self::$path, self::$user, self::$pass);
    }

    
    private function __clone()
    {
        
    }

    public static function instance()
    {
        if (is_null(self::$instance))
        {
            new Connection();
        }
        return self::$instance;
    }
}