<?php
class TestDurationListener extends PHPUnit_Framework_BaseTestListener
{
    public function endTest(PHPUnit_Framework_Test $test, $time)
    {
        echo "resource useage" . PHP_Timer::resourceUsage() . "\n";
    }
}
