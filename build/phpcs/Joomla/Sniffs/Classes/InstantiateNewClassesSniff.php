<?php
/**
 * Ensures that new classes are instantiated without brackets if they do not
 * have any parameters.
 *
 * @category  Classes
 * @package   Joomla.CodeSniffer
 * @author    Nikolai Plath
 * @license   GNU General Public License version 2 or later
 */

/**
 * Ensures that new classes are instantiated without brackets if they do not
 * have any parameters.
 *
 * @category  Classes
 * @package   Joomla.CodeSniffer
 */
class Joomla_Sniffs_Classes_InstantiateNewClassesSniff implements PHP_CodeSniffer_Sniff
{
    /**
     * Registers the token types that this sniff wishes to listen to.
     *
     * @return array
     */
    public function register()
    {
        return array(T_NEW);
    }//end register()

    /**
     * Process the tokens that this sniff is listening for.
     *
     * @param PHP_CodeSniffer_File $phpcsFile The file where the token was found.
     * @param int                  $stackPtr  The position in the stack where
     *                                        the token was found.
     * 
     * @return void
     * @TODO  improve handling for Instantiate New Classes when there is whitespace between the PARENTHESIS
     */
    public function process(PHP_CodeSniffer_File $phpcsFile, $stackPtr)
    {
        $tokens = $phpcsFile->getTokens();

        if($tokens[($stackPtr)]['code'] === T_OPEN_PARENTHESIS && $tokens[($stackPtr + 1)]['code'] === T_CLOSE_PARENTHESIS)
        {
            $error = 'Instanciating new classes without parameters does not require brackets.';
            $phpcsFile->addError($error, $stackPtr, 'New class');
        }
    }//function
}//class
