#!/usr/bin/env php
<?php
/**
 * setup an Nginx default server proxy template.
 * Used for docker container created by Abdulrahman Dimashki <idimsh@gmail.com>
 */
define( 'DEFAULT_PHP_VERSION', '7.4' );

function print_e( ...$input ) {
  fwrite( STDERR, implode( ' ', $input ) . "\n" );
}

$versions = explode( " ", file( __DIR__ . '/php-versions.txt' )[0] );

$PHP_VERSION = getenv( 'PHP_VERSION' );
$LOG_TO_SRV  = getenv( 'LOG_TO_SRV' );
$DOCROOT     = getenv( 'DOCROOT' );

if ( ! in_array( $PHP_VERSION, $versions ) ) {
  $PHP_VERSION = DEFAULT_PHP_VERSION;
  print_e( "PHP version does not match or not given, set to: {$PHP_VERSION}" );
}

$dest_extra_files = [
  'default_server_proxy' => [
    'template' => '/etc/nginx/default_server.proxy.template',
    'dest'     => '/etc/nginx/default_server.proxy',
  ],
  'default_server_conf'  => [
    'template' => '/etc/nginx/default_server.conf.template',
    'dest'     => '/etc/nginx/default_server.conf',
  ],
];

foreach ( $dest_extra_files as $files_array ) {
  if ( ! file_put_contents( $files_array['dest'], replace_templates( file_get_contents( $files_array['template'] ) ) ) ) {
    print_e( "error creating file [{$files_array['dest']}]" );
    exit( 1 );
  }
}


/**
 * Variables in default proxy templates:
 * {if-php-7.1}: block
 * {if-php-7.2}: block
 * {if-php-7.3}: block
 * ---
 * User Include Files:
 * /etc/nginx/default_server.proxy.template
 * /etc/nginx/default_server.proxy
 *
 *
 * Variables in default_server_conf templates:
 * {if-LOG_TO_SRV}: block
 * {if-not-LOG_TO_SRV}: block
 */

/**
 * This is special to replace conditional Blocks depending on condition passed.
 *
 * @param $condition
 * @param $start_string
 * @param $end_string
 * @param $input_string
 *
 * @return null|string|string[]
 */
function preg_replace_conditional( $condition, $start_string, $end_string, $input_string ) {
  $pattern_start = preg_quote( $start_string, '@' );
  $pattern_end   = preg_quote( $end_string, '@' );
  if ( $condition ) {
    $pattern_start = "@{$pattern_start}.*\\n@";
    $pattern_end   = "@{$pattern_end}.*\\n@";
    $input_string  = preg_replace( $pattern_start, '', $input_string );
    $input_string  = preg_replace( $pattern_end, '', $input_string );
  } else {
    // non greedy match which matches new line also with 's' modifier.
    $pattern      = "@{$pattern_start}.*?{$pattern_end}\\n?@s";
    $input_string = preg_replace( $pattern, '', $input_string );
  }

  return $input_string;
}

/**
 * This will replace the content of  the input string moving through all defined
 * template variables
 *
 * @param $input_string
 *
 * @return mixed|null|string|string[]
 */
function replace_templates( $input_string ) {
  global $PHP_VERSION, $LOG_TO_SRV, $DOCROOT;

  $output = str_replace( "\r", "", $input_string );

  $output = preg_replace_conditional( $PHP_VERSION == '7.1', '{if-php-7.1}', '{/if-php-7.1}', $output );
  $output = preg_replace_conditional( $PHP_VERSION == '7.2', '{if-php-7.2}', '{/if-php-7.2}', $output );
  $output = preg_replace_conditional( $PHP_VERSION == '7.3', '{if-php-7.3}', '{/if-php-7.3}', $output );
  $output = preg_replace_conditional( $PHP_VERSION == '7.4', '{if-php-7.4}', '{/if-php-7.4}', $output );

  $output = preg_replace_conditional( ! empty( $LOG_TO_SRV ), '{if-LOG_TO_SRV}', '{/if-LOG_TO_SRV}', $output );
  $output = preg_replace_conditional( empty( $LOG_TO_SRV ), '{if-not-LOG_TO_SRV}', '{/if-not-LOG_TO_SRV}', $output );

  $output = str_replace( '${DOCROOT}', $DOCROOT, $output );

  return $output;
}

