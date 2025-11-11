<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * Localized language
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** Database username */
define( 'DB_USER', 'wpuser' );

/** Database password */
define( 'DB_PASSWORD', 'password' );

/** Database hostname */
define( 'DB_HOST', 'mariadb' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',          '}K`YpH6addY@&,JdWzZ0Xol?3AcH]6hT!P)Ju2yOUH,c2%by+&h/A2<1@`bIKSb[' );
define( 'SECURE_AUTH_KEY',   'nwg(vnYE&S^ smZ.x.{Y12B%4Ns9QEZtz*WWdWN9n8kIDFg%ZyYGONNc$z.L#/Z`' );
define( 'LOGGED_IN_KEY',     '/5Z&G%~cg8HwbB`|uQQ^+Y!~swwV90hj@sUMm]Y[r!&eN_PY_.hLQk(Iu,lchUvl' );
define( 'NONCE_KEY',         ',q+Puaj0>Ebs_*Y|OO6IC+?9dQv<NvOQ;B+}vr/G[4~D^qzt~X:^vw`{ FLK]s _' );
define( 'AUTH_SALT',         'l^*Vgc{qLI`-&&VfRU`SG{qvi7N4p=q}F#U0NLTf=>n!#38pm]:qH_4}*r,:*MY ' );
define( 'SECURE_AUTH_SALT',  'm[LY}J=sj*e9yrrI7x+1iVD/nY28#v/Bmk%W9 Ei:=lxppZeW})TvyBVanIW2@zi' );
define( 'LOGGED_IN_SALT',    'Vuw{t:y&J;ytxvphxFm(x|y@3KCR<E8]Lf]kByaV2@`Wp~h]k#!j+s{@IT(#_pOu' );
define( 'NONCE_SALT',        'h6D0;ah0acu>!!C(a*rHfEt~VKd946me}@hsJ~&)BDy:P#{N@{-|h>)Gb*y,k@4a' );
define( 'WP_CACHE_KEY_SALT', '&JYZ_??KEBw1BGPir9I#9{6=v,;hmdp~)^lqQ&0,EPbD+(s3$OJJOdtQp>;!|jg*' );


/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';


/* Add any custom values between this line and the "stop editing" line. */



/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
if ( ! defined( 'WP_DEBUG' ) ) {
	define( 'WP_DEBUG', false );
}

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
