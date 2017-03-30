<?php
/**
 * @package    Joomla.Platform
 *
 * @copyright  Copyright (C) 2005 - 2017 Open Source Matters, Inc. All rights reserved.
 * @license    GNU General Public License version 2 or later; see LICENSE
 */

defined('JPATH_PLATFORM') or die;

use Joomla\Registry\Registry;

/**
 * Joomla Factory class for CLI.
 *
 * @since  __DEPLOY_VERSION__
 */
class JFactoryCli extends JFactory
{
	/**
	 * Global application object
	 *
	 * @var    JApplicationCli
	 * @since  __DEPLOY_VERSION__
	 */
	public static $application = null;

	/**
	 * Get an application object.
	 *
	 * Returns the global {@link JApplicationCli} object, only creating it if it doesn't already exist.
	 *
	 * @param   mixed   $id      A client identifier or name.
	 * @param   array   $config  An optional associative array of configuration settings.
	 * @param   string  $prefix  Application prefix
	 *
	 * @return  JApplicationCli object
	 *
	 * @see     JApplication
	 * @since   __DEPLOY_VERSION__
	 * @throws  Exception
	 */
	public static function getApplication($id = null, array $config = array(), $prefix = 'J')
	{
		if (!self::$application)
		{
			if (!$id)
			{
				throw new Exception('Application Instantiation Error', 500);
			}

			self::$application = JApplicationCli::getInstance($id);
		}

		return self::$application;
	}
}
