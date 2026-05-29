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
class TranslationsEs extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEs _root = this; // ignore: unused_field

	@override 
	TranslationsEs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override String get nav_home => 'Inicio';
	@override String get nav_search => 'Buscar';
	@override String get nav_my_lists => 'Mis Listas';
	@override String get nav_recommend => 'Recomendar';
	@override String get nav_social => 'Social';
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
	@override String get series_detail_add_to_list => 'Añadir a Lista';
	@override String get series_detail_manage_tracking => 'Gestionar';
	@override String get series_detail_overview => 'Resumen';
	@override String get series_detail_no_description => 'No hay descripción disponible.';
	@override String get series_detail_show_more => 'Mostrar más';
	@override String get series_detail_show_less => 'Mostrar menos';
	@override String get series_detail_episodes => 'Episodios';
	@override String get series_detail_tmdb_rating => 'Valoración TMDB';
	@override String series_detail_vote_count({required Object count}) => '${count} votos';
	@override String get series_detail_more_details => 'Más detalles';
	@override String get series_detail_created_by => 'Creado por';
	@override String get series_detail_origin_country => 'País de origen';
	@override String get series_detail_type => 'Tipo';
	@override String get series_detail_popularity => 'Popularidad';
	@override String get series_detail_last_episode => 'Último episodio';
	@override String get series_detail_next_episode => 'Próximo episodio';
	@override String series_detail_episode_code({required Object season, required Object episode}) => 'T${season}E${episode}';
	@override String get series_detail_episode_date => '{code} · {date}';
	@override String get series_detail_not_available => '—';
	@override String get series_detail_first_air_date => 'Primera Emisión';
	@override String get series_detail_seasons => 'Temporadas';
	@override String get series_detail_networks => 'Redes';
	@override String get series_detail_status => 'Estado';
	@override String get series_detail_rating => 'Valoración';
	@override String get series_detail_review => 'Reseña (opcional)';
	@override String get series_detail_save_changes => 'Guardar Cambios';
	@override String get series_detail_remove_from_list => 'Eliminar de Lista';
	@override String series_detail_remove_confirm({required Object title}) => '¿Eliminar "${title}" de tu lista?';
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
	@override String get media_type_series => 'Series';
	@override String get media_type_movies => 'Películas';
	@override String get search_hint_movies => 'Buscar películas...';
	@override String get search_no_results_movies => 'No se encontraron películas';
	@override String get tracking_empty_movies => 'Aún no hay películas en {status}';
	@override String get dashboard_empty_movies => 'Todavía no hay películas registradas.\nBusca y agrega tu primera película!';
	@override String movie_detail_error({required Object message}) => 'Error: ${message}';
	@override String get movie_detail_loading => 'Cargando detalles de la película...';
	@override String get movie_detail_release_date => 'Fecha de estreno';
	@override String get movie_detail_runtime => 'Duración';
	@override String get movie_detail_runtime_minutes => '{minutes} min';
	@override String get recommend_coming_soon => '¡Función de recomendación próximamente!';
	@override String get error_retry => 'Reintentar';
	@override String get error_network => 'Error de red. Verifica tu conexión.';
	@override String get error_server => 'Error del servidor. Inténtalo de nuevo más tarde.';
	@override String get error_session_expired => 'Sesión expirada. Inicia sesión de nuevo.';
	@override String get error_resource_not_found => 'Recurso no encontrado.';
	@override String get social_load_error => 'No se pudo cargar Social.';
	@override String get social_my_profile => 'Mi perfil →';
	@override String get social_feed_load_error => 'Error al cargar el feed.';
	@override String get social_discover_empty => 'No hay sugerencias por ahora.';
	@override String get social_follow_error => 'No se pudo seguir a este usuario.';
	@override String get social_try_again => 'Intentar de nuevo';
	@override String get social_display_name => 'Nombre para mostrar';
	@override String get social_avatar_url => 'URL del avatar';
	@override String get social_privacy => 'Privacidad';
	@override String get social_public => 'Público';
	@override String get social_private => 'Privado';
	@override String get social_save_profile => 'Guardar perfil';
	@override String get social_finish => 'Finalizar';
	@override String get social_discover_people_cta => 'Descubrir personas';
	@override String get social_edit_profile => 'Editar perfil';
	@override String get social_public_profile => 'Perfil público';
	@override String get social_save_changes => 'Guardar cambios';
	@override String get social_profile_load_error => 'No se pudo cargar tu perfil social.';
	@override String get social_profile_save_error => 'No se pudo guardar el perfil. Inténtalo de nuevo.';
	@override String get social_empty_people => 'No hay personas para mostrar.';
	@override String get social_list_load_error => 'Error al cargar la lista.';
	@override String get social_activity => 'Actividad';
	@override String get social_lists => 'Listas';
	@override String get social_followers => 'Seguidores';
	@override String get social_following => 'Siguiendo';
	@override String get social_profile_unavailable => 'Este perfil no está disponible en este momento.';
	@override String get social_empty_public_activity => 'Aún no hay actividad pública.';
	@override String social_section_load_error({required Object section}) => 'No se pudo cargar ${section}.';
	@override String social_section_loading({required Object section}) => 'Cargando ${section}...';
	@override String social_followers_count({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(count,
		one: '${count} seguidor',
		other: '${count} seguidores',
	);
	@override String social_following_count({required Object count}) => '${count} siguiendo';
	@override String social_affinity({required Object percent}) => '${percent}% de afinidad';
	@override String get social_follow => 'Seguir';
	@override String get social_unfollow => 'Dejar de seguir';
	@override String get social_follow_updating_semantics => 'Actualizando seguimiento';
	@override String get social_following_action => 'Siguiendo';
	@override String get social_following_user_semantics => 'Siguiendo usuario';
	@override String get social_feed => 'Feed';
	@override String get social_discover => 'Descubrir';
	@override String get social_empty_feed_title => 'Tu feed está vacío';
	@override String get social_empty_feed_body => 'Sigue personas para ver su actividad aquí.';
	@override String get social_discover_people => 'Descubrir personas';
	@override String get social_create_profile_title => 'Crea tu perfil social';
	@override String get social_display_name_required => 'Ingresa un nombre para mostrar';
	@override String get social_privacy_required => 'Elige la privacidad del perfil';
	@override String get social_follow_suggestions => 'Sugerencias para seguir';
	@override String get social_discover_timeout => 'Discover tardó demasiado en responder. Inténtalo de nuevo en unos instantes.';
	@override String get social_discover_error => 'Error al descubrir personas.';
	@override String get social_edit_profile_title => 'Editar perfil social';
	@override String get social_public_lists_title => 'Listas públicas';
	@override String get social_status_plan_to_watch => 'Quiero ver';
	@override String get social_status_watching => 'Viendo';
	@override String get social_status_completed => 'Completado';
	@override String get social_status_dropped => 'Abandonado';
	@override String social_public_list_empty({required Object section}) => 'No hay elementos en ${section}.';
	@override String get dashboard_social_preview_title => 'Actividad social';
	@override String get dashboard_social_preview_body => 'Mira qué están viendo y calificando otros fans.';
	@override String get dashboard_social_preview_cta => 'Abrir Social';
	@override String get dashboard_recommendation_title => 'Recomendaciones para ti';
	@override String get dashboard_recommendation_body => 'Encuentra algo personalizado para ver después.';
	@override String get dashboard_recommendation_cta => 'Obtener recomendaciones';
	@override String get nav_change_language_tooltip => 'Cambiar idioma';
	@override String get nav_sign_out_tooltip => 'Cerrar sesión';
	@override String get search_clear_tooltip => 'Borrar búsqueda';
	@override String get auth_resend_confirmation_code => 'Reenviar código de confirmación';
	@override String get social_public_list_empty_default => 'Aún no hay elementos públicos.';
	@override String social_open_media_semantics({required Object title}) => 'Abrir ${title}';
	@override String get social_media_type_movie => 'Película';
	@override String get social_media_type_series => 'Serie';
	@override String dashboard_social_profile_label({required Object name}) => 'Perfil social: ${name}';
	@override String get social_activity_rated => 'calificó';
	@override String get social_activity_reviewed => 'escribió una reseña de';
	@override String get social_activity_completed => 'completó';
	@override String get social_activity_started_watching => 'empezó';
	@override String get social_activity_dropped => 'abandonó';
	@override String get social_activity_added_to_list => 'agregó a la lista';
	@override String get social_activity_interacted_with => 'interactuó con';
	@override String get auth_error_email_password_required => 'Ingresa e-mail y contraseña';
	@override String get auth_error_invalid_credentials => 'E-mail o contraseña incorrectos';
	@override String get auth_error_email_required => 'Ingresa tu e-mail';
	@override String get auth_error_send_code => 'Error al enviar el código. Inténtalo de nuevo.';
	@override String get auth_error_passwords_do_not_match => 'Las contraseñas no coinciden';
	@override String get auth_error_fill_all_fields => 'Completa todos los campos';
	@override String get auth_error_reset_password => 'Error al restablecer la contraseña. Inténtalo de nuevo.';
	@override String get auth_error_password_too_weak => 'La contraseña es muy débil';
	@override String get auth_error_accept_terms => 'Acepta los términos de uso';
	@override String get auth_error_email_already_registered => 'Este email ya está registrado. Inicia sesión o usa otro email.';
	@override String get auth_error_create_account => 'Error al crear la cuenta. Inténtalo de nuevo.';
	@override String get auth_error_confirmation_code_required => 'Ingresa el código de confirmación';
	@override String get auth_error_invalid_code => 'Código inválido. Inténtalo de nuevo.';
	@override String get auth_error_resend_code => 'No se pudo reenviar el código. Inténtalo de nuevo.';
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
			'nav_social' => 'Social',
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
			'series_detail_add_to_list' => 'Añadir a Lista',
			'series_detail_manage_tracking' => 'Gestionar',
			'series_detail_overview' => 'Resumen',
			'series_detail_no_description' => 'No hay descripción disponible.',
			'series_detail_show_more' => 'Mostrar más',
			'series_detail_show_less' => 'Mostrar menos',
			'series_detail_episodes' => 'Episodios',
			'series_detail_tmdb_rating' => 'Valoración TMDB',
			'series_detail_vote_count' => ({required Object count}) => '${count} votos',
			'series_detail_more_details' => 'Más detalles',
			'series_detail_created_by' => 'Creado por',
			'series_detail_origin_country' => 'País de origen',
			'series_detail_type' => 'Tipo',
			'series_detail_popularity' => 'Popularidad',
			'series_detail_last_episode' => 'Último episodio',
			'series_detail_next_episode' => 'Próximo episodio',
			'series_detail_episode_code' => ({required Object season, required Object episode}) => 'T${season}E${episode}',
			'series_detail_episode_date' => '{code} · {date}',
			'series_detail_not_available' => '—',
			'series_detail_first_air_date' => 'Primera Emisión',
			'series_detail_seasons' => 'Temporadas',
			'series_detail_networks' => 'Redes',
			'series_detail_status' => 'Estado',
			'series_detail_rating' => 'Valoración',
			'series_detail_review' => 'Reseña (opcional)',
			'series_detail_save_changes' => 'Guardar Cambios',
			'series_detail_remove_from_list' => 'Eliminar de Lista',
			'series_detail_remove_confirm' => ({required Object title}) => '¿Eliminar "${title}" de tu lista?',
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
			'media_type_series' => 'Series',
			'media_type_movies' => 'Películas',
			'search_hint_movies' => 'Buscar películas...',
			'search_no_results_movies' => 'No se encontraron películas',
			'tracking_empty_movies' => 'Aún no hay películas en {status}',
			'dashboard_empty_movies' => 'Todavía no hay películas registradas.\nBusca y agrega tu primera película!',
			'movie_detail_error' => ({required Object message}) => 'Error: ${message}',
			'movie_detail_loading' => 'Cargando detalles de la película...',
			'movie_detail_release_date' => 'Fecha de estreno',
			'movie_detail_runtime' => 'Duración',
			'movie_detail_runtime_minutes' => '{minutes} min',
			'recommend_coming_soon' => '¡Función de recomendación próximamente!',
			'error_retry' => 'Reintentar',
			'error_network' => 'Error de red. Verifica tu conexión.',
			'error_server' => 'Error del servidor. Inténtalo de nuevo más tarde.',
			'error_session_expired' => 'Sesión expirada. Inicia sesión de nuevo.',
			'error_resource_not_found' => 'Recurso no encontrado.',
			'social_load_error' => 'No se pudo cargar Social.',
			'social_my_profile' => 'Mi perfil →',
			'social_feed_load_error' => 'Error al cargar el feed.',
			'social_discover_empty' => 'No hay sugerencias por ahora.',
			'social_follow_error' => 'No se pudo seguir a este usuario.',
			'social_try_again' => 'Intentar de nuevo',
			'social_display_name' => 'Nombre para mostrar',
			'social_avatar_url' => 'URL del avatar',
			'social_privacy' => 'Privacidad',
			'social_public' => 'Público',
			'social_private' => 'Privado',
			'social_save_profile' => 'Guardar perfil',
			'social_finish' => 'Finalizar',
			'social_discover_people_cta' => 'Descubrir personas',
			'social_edit_profile' => 'Editar perfil',
			'social_public_profile' => 'Perfil público',
			'social_save_changes' => 'Guardar cambios',
			'social_profile_load_error' => 'No se pudo cargar tu perfil social.',
			'social_profile_save_error' => 'No se pudo guardar el perfil. Inténtalo de nuevo.',
			'social_empty_people' => 'No hay personas para mostrar.',
			'social_list_load_error' => 'Error al cargar la lista.',
			'social_activity' => 'Actividad',
			'social_lists' => 'Listas',
			'social_followers' => 'Seguidores',
			'social_following' => 'Siguiendo',
			'social_profile_unavailable' => 'Este perfil no está disponible en este momento.',
			'social_empty_public_activity' => 'Aún no hay actividad pública.',
			'social_section_load_error' => ({required Object section}) => 'No se pudo cargar ${section}.',
			'social_section_loading' => ({required Object section}) => 'Cargando ${section}...',
			'social_followers_count' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(count, one: '${count} seguidor', other: '${count} seguidores', ), 
			'social_following_count' => ({required Object count}) => '${count} siguiendo',
			'social_affinity' => ({required Object percent}) => '${percent}% de afinidad',
			'social_follow' => 'Seguir',
			'social_unfollow' => 'Dejar de seguir',
			'social_follow_updating_semantics' => 'Actualizando seguimiento',
			'social_following_action' => 'Siguiendo',
			'social_following_user_semantics' => 'Siguiendo usuario',
			'social_feed' => 'Feed',
			'social_discover' => 'Descubrir',
			'social_empty_feed_title' => 'Tu feed está vacío',
			'social_empty_feed_body' => 'Sigue personas para ver su actividad aquí.',
			'social_discover_people' => 'Descubrir personas',
			'social_create_profile_title' => 'Crea tu perfil social',
			'social_display_name_required' => 'Ingresa un nombre para mostrar',
			'social_privacy_required' => 'Elige la privacidad del perfil',
			'social_follow_suggestions' => 'Sugerencias para seguir',
			'social_discover_timeout' => 'Discover tardó demasiado en responder. Inténtalo de nuevo en unos instantes.',
			'social_discover_error' => 'Error al descubrir personas.',
			'social_edit_profile_title' => 'Editar perfil social',
			'social_public_lists_title' => 'Listas públicas',
			'social_status_plan_to_watch' => 'Quiero ver',
			'social_status_watching' => 'Viendo',
			'social_status_completed' => 'Completado',
			'social_status_dropped' => 'Abandonado',
			'social_public_list_empty' => ({required Object section}) => 'No hay elementos en ${section}.',
			'dashboard_social_preview_title' => 'Actividad social',
			'dashboard_social_preview_body' => 'Mira qué están viendo y calificando otros fans.',
			'dashboard_social_preview_cta' => 'Abrir Social',
			'dashboard_recommendation_title' => 'Recomendaciones para ti',
			'dashboard_recommendation_body' => 'Encuentra algo personalizado para ver después.',
			'dashboard_recommendation_cta' => 'Obtener recomendaciones',
			'nav_change_language_tooltip' => 'Cambiar idioma',
			'nav_sign_out_tooltip' => 'Cerrar sesión',
			'search_clear_tooltip' => 'Borrar búsqueda',
			'auth_resend_confirmation_code' => 'Reenviar código de confirmación',
			'social_public_list_empty_default' => 'Aún no hay elementos públicos.',
			'social_open_media_semantics' => ({required Object title}) => 'Abrir ${title}',
			'social_media_type_movie' => 'Película',
			'social_media_type_series' => 'Serie',
			'dashboard_social_profile_label' => ({required Object name}) => 'Perfil social: ${name}',
			'social_activity_rated' => 'calificó',
			'social_activity_reviewed' => 'escribió una reseña de',
			'social_activity_completed' => 'completó',
			'social_activity_started_watching' => 'empezó',
			'social_activity_dropped' => 'abandonó',
			'social_activity_added_to_list' => 'agregó a la lista',
			'social_activity_interacted_with' => 'interactuó con',
			'auth_error_email_password_required' => 'Ingresa e-mail y contraseña',
			'auth_error_invalid_credentials' => 'E-mail o contraseña incorrectos',
			'auth_error_email_required' => 'Ingresa tu e-mail',
			'auth_error_send_code' => 'Error al enviar el código. Inténtalo de nuevo.',
			'auth_error_passwords_do_not_match' => 'Las contraseñas no coinciden',
			'auth_error_fill_all_fields' => 'Completa todos los campos',
			'auth_error_reset_password' => 'Error al restablecer la contraseña. Inténtalo de nuevo.',
			'auth_error_password_too_weak' => 'La contraseña es muy débil',
			'auth_error_accept_terms' => 'Acepta los términos de uso',
			'auth_error_email_already_registered' => 'Este email ya está registrado. Inicia sesión o usa otro email.',
			'auth_error_create_account' => 'Error al crear la cuenta. Inténtalo de nuevo.',
			'auth_error_confirmation_code_required' => 'Ingresa el código de confirmación',
			'auth_error_invalid_code' => 'Código inválido. Inténtalo de nuevo.',
			'auth_error_resend_code' => 'No se pudo reenviar el código. Inténtalo de nuevo.',
			_ => null,
		};
	}
}
