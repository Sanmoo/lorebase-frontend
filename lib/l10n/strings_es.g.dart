///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsEs with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsEs _root = this; // ignore: unused_field

	@override 
	TranslationsEs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override String get nav_home => 'Inicio';
	@override String get nav_search => 'Buscar';
	@override String get nav_my_lists => 'Mis Listas';
	@override String get nav_recommend => 'Recomendar';
	@override String get app_title => 'Lorebase';
	@override String get login_welcome => 'Bienvenido de nuevo';
	@override String get login_subtitle => 'Inicia sesión para continuar tus listas';
	@override String get login_email_hint => 'Correo electrónico';
	@override String get login_password_hint => 'Contraseña';
	@override String get login_button => 'Iniciar sesión';
	@override String get login_forgot_password => '¿Olvidaste tu contraseña?';
	@override String get login_no_account => '¿No tienes cuenta? ';
	@override String get login_sign_up => 'Regístrate';
	@override String get login_or => 'o';
	@override String get search_hint => 'Buscar series...';
	@override String get search_empty => 'Escribe al menos 2 caracteres para buscar';
	@override String get search_no_results => 'No se encontraron series';
	@override String get tracking_want_to_watch => 'Quiero Ver';
	@override String get tracking_watching => 'Viendo';
	@override String get tracking_completed => 'Completado';
	@override String get tracking_dropped => 'Abandonado';
	@override String get tracking_empty => 'No hay series {status} todavía';
	@override String get tracking_list_title => 'Mis Listas';
	@override String get series_detail_add_to_list => 'Añadir a Lista';
	@override String get series_detail_manage_tracking => 'Gestionar';
	@override String get series_detail_overview => 'Resumen';
	@override String get series_detail_no_description => 'No hay descripción disponible.';
	@override String get series_detail_show_more => 'Mostrar más';
	@override String get series_detail_show_less => 'Mostrar menos';
	@override String get series_detail_first_air_date => 'Primera Emisión';
	@override String get series_detail_seasons => 'Temporadas';
	@override String get series_detail_networks => 'Redes';
	@override String get series_detail_status => 'Estado';
	@override String get series_detail_rating => 'Valoración';
	@override String get series_detail_review => 'Reseña (opcional)';
	@override String get series_detail_save_changes => 'Guardar Cambios';
	@override String get series_detail_remove_from_list => 'Eliminar de Lista';
	@override String get series_detail_remove_confirm => '¿Eliminar "{title}" de tu lista?';
	@override String get series_detail_cancel => 'Cancelar';
	@override String get series_detail_remove => 'Eliminar';
	@override String get series_detail_loading => 'Cargando detalles de la serie...';
	@override String get series_detail_season_count => '{count} {count, plural, one{temporada} other{temporadas}}';
	@override String get dashboard_loading => 'Cargando tu tablero...';
	@override String get dashboard_empty => 'Aún no hay series registradas.\n¡Busca y añade tu primera serie!';
	@override String get dashboard_watching => 'Viendo';
	@override String get dashboard_want_to_watch => 'Quiero Ver';
	@override String get dashboard_completed => 'Completado';
	@override String get dashboard_dropped => 'Abandonado';
	@override String get auth_create_account => 'Crear cuenta';
	@override String get auth_confirm_email => 'Confirma tu correo';
	@override String get auth_code_sent_to => 'Ingresa el código enviado a {email}';
	@override String get auth_confirmation_code => 'Código de confirmación';
	@override String get auth_confirm_and_login => 'Confirmar e iniciar sesión';
	@override String get auth_resend_code => 'Reenviar código';
	@override String get auth_password_weak => 'Débil';
	@override String get auth_password_medium => 'Media';
	@override String get auth_password_strong => 'Fuerte';
	@override String get auth_accept_terms => 'Acepto los Términos de Uso';
	@override String get auth_already_have_account => '¿Ya tienes cuenta? ';
	@override String get auth_sign_in => 'Iniciar sesión';
	@override String get auth_recover_password => 'Recuperar contraseña';
	@override String get auth_new_password_title => 'Nueva contraseña';
	@override String get auth_email_hint => 'Correo electrónico';
	@override String get auth_password_hint => 'Contraseña';
	@override String get auth_confirm_password_hint => 'Confirmar contraseña';
	@override String get auth_send_code => 'Enviar código';
	@override String get auth_verification_code_hint => 'Código de verificación';
	@override String get auth_new_password_hint => 'Nueva contraseña';
	@override String get auth_confirm_new_password_hint => 'Confirmar nueva contraseña';
	@override String get auth_reset_password => 'Restablecer contraseña';
	@override String get auth_code_sent_success => 'Código enviado a tu correo';
	@override String get auth_password_reset_success => 'Contraseña restablecida exitosamente';
	@override String get auth_back_to_login => 'Volver al inicio de sesión';
	@override String get auth_sign_up => 'Regístrate';
	@override String get auth_forgot_subtitle_request => 'Ingresa tu correo para recibir un código de verificación';
	@override String get auth_forgot_subtitle_reset => 'Ingresa el código enviado a tu correo y tu nueva contraseña';
	@override String get locale_pt_BR => 'Português';
	@override String get locale_en_US => 'English';
	@override String get locale_es => 'Español';
	@override String get recommend_title => 'Recomendación';
	@override String get recommend_coming_soon => '¡Función de recomendación próximamente!';
	@override String get error_network => 'Error de red. Verifica tu conexión.';
	@override String get error_server => 'Error del servidor. Inténtalo de nuevo más tarde.';
	@override String get error_session_expired => 'Sesión expirada. Inicia sesión de nuevo.';
	@override String get error_resource_not_found => 'Recurso no encontrado.';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'nav_home' => 'Inicio',
			'nav_search' => 'Buscar',
			'nav_my_lists' => 'Mis Listas',
			'nav_recommend' => 'Recomendar',
			'app_title' => 'Lorebase',
			'login_welcome' => 'Bienvenido de nuevo',
			'login_subtitle' => 'Inicia sesión para continuar tus listas',
			'login_email_hint' => 'Correo electrónico',
			'login_password_hint' => 'Contraseña',
			'login_button' => 'Iniciar sesión',
			'login_forgot_password' => '¿Olvidaste tu contraseña?',
			'login_no_account' => '¿No tienes cuenta? ',
			'login_sign_up' => 'Regístrate',
			'login_or' => 'o',
			'search_hint' => 'Buscar series...',
			'search_empty' => 'Escribe al menos 2 caracteres para buscar',
			'search_no_results' => 'No se encontraron series',
			'tracking_want_to_watch' => 'Quiero Ver',
			'tracking_watching' => 'Viendo',
			'tracking_completed' => 'Completado',
			'tracking_dropped' => 'Abandonado',
			'tracking_empty' => 'No hay series {status} todavía',
			'tracking_list_title' => 'Mis Listas',
			'series_detail_add_to_list' => 'Añadir a Lista',
			'series_detail_manage_tracking' => 'Gestionar',
			'series_detail_overview' => 'Resumen',
			'series_detail_no_description' => 'No hay descripción disponible.',
			'series_detail_show_more' => 'Mostrar más',
			'series_detail_show_less' => 'Mostrar menos',
			'series_detail_first_air_date' => 'Primera Emisión',
			'series_detail_seasons' => 'Temporadas',
			'series_detail_networks' => 'Redes',
			'series_detail_status' => 'Estado',
			'series_detail_rating' => 'Valoración',
			'series_detail_review' => 'Reseña (opcional)',
			'series_detail_save_changes' => 'Guardar Cambios',
			'series_detail_remove_from_list' => 'Eliminar de Lista',
			'series_detail_remove_confirm' => '¿Eliminar "{title}" de tu lista?',
			'series_detail_cancel' => 'Cancelar',
			'series_detail_remove' => 'Eliminar',
			'series_detail_loading' => 'Cargando detalles de la serie...',
			'series_detail_season_count' => '{count} {count, plural, one{temporada} other{temporadas}}',
			'dashboard_loading' => 'Cargando tu tablero...',
			'dashboard_empty' => 'Aún no hay series registradas.\n¡Busca y añade tu primera serie!',
			'dashboard_watching' => 'Viendo',
			'dashboard_want_to_watch' => 'Quiero Ver',
			'dashboard_completed' => 'Completado',
			'dashboard_dropped' => 'Abandonado',
			'auth_create_account' => 'Crear cuenta',
			'auth_confirm_email' => 'Confirma tu correo',
			'auth_code_sent_to' => 'Ingresa el código enviado a {email}',
			'auth_confirmation_code' => 'Código de confirmación',
			'auth_confirm_and_login' => 'Confirmar e iniciar sesión',
			'auth_resend_code' => 'Reenviar código',
			'auth_password_weak' => 'Débil',
			'auth_password_medium' => 'Media',
			'auth_password_strong' => 'Fuerte',
			'auth_accept_terms' => 'Acepto los Términos de Uso',
			'auth_already_have_account' => '¿Ya tienes cuenta? ',
			'auth_sign_in' => 'Iniciar sesión',
			'auth_recover_password' => 'Recuperar contraseña',
			'auth_new_password_title' => 'Nueva contraseña',
			'auth_email_hint' => 'Correo electrónico',
			'auth_password_hint' => 'Contraseña',
			'auth_confirm_password_hint' => 'Confirmar contraseña',
			'auth_send_code' => 'Enviar código',
			'auth_verification_code_hint' => 'Código de verificación',
			'auth_new_password_hint' => 'Nueva contraseña',
			'auth_confirm_new_password_hint' => 'Confirmar nueva contraseña',
			'auth_reset_password' => 'Restablecer contraseña',
			'auth_code_sent_success' => 'Código enviado a tu correo',
			'auth_password_reset_success' => 'Contraseña restablecida exitosamente',
			'auth_back_to_login' => 'Volver al inicio de sesión',
			'auth_sign_up' => 'Regístrate',
			'auth_forgot_subtitle_request' => 'Ingresa tu correo para recibir un código de verificación',
			'auth_forgot_subtitle_reset' => 'Ingresa el código enviado a tu correo y tu nueva contraseña',
			'locale_pt_BR' => 'Português',
			'locale_en_US' => 'English',
			'locale_es' => 'Español',
			'recommend_title' => 'Recomendación',
			'recommend_coming_soon' => '¡Función de recomendación próximamente!',
			'error_network' => 'Error de red. Verifica tu conexión.',
			'error_server' => 'Error del servidor. Inténtalo de nuevo más tarde.',
			'error_session_expired' => 'Sesión expirada. Inicia sesión de nuevo.',
			'error_resource_not_found' => 'Recurso no encontrado.',
			_ => null,
		};
	}
}
