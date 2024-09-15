<?php

class Connection
{
    private static $instance = NULL;
    private static $path = "";
    private static $user = "root";
    private static $pass = "";

    private function __construct()
    {
        self::$instance = new PDO
    }

    
    private function __clone()
    {
        
    }

    public static function instance()
    {
        if (is_null(self::$instance))
        {
            new Conection();
        }
        return self::$instance
    }
}