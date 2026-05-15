///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'Lorebase'
	String get app_title => 'Lorebase';

	/// en: 'I accept the Terms of Use'
	String get auth_accept_terms => 'I accept the Terms of Use';

	/// en: 'Already have an account? '
	String get auth_already_have_account => 'Already have an account? ';

	/// en: 'Back to login'
	String get auth_back_to_login => 'Back to login';

	/// en: 'Code sent to your email'
	String get auth_code_sent_success => 'Code sent to your email';

	/// en: 'Enter code sent to {email}'
	String get auth_code_sent_to => 'Enter code sent to {email}';

	/// en: 'Confirmation code'
	String get auth_confirmation_code => 'Confirmation code';

	/// en: 'Confirm & Sign in'
	String get auth_confirm_and_login => 'Confirm & Sign in';

	/// en: 'Confirm your email'
	String get auth_confirm_email => 'Confirm your email';

	/// en: 'Confirm new password'
	String get auth_confirm_new_password_hint => 'Confirm new password';

	/// en: 'Confirm password'
	String get auth_confirm_password_hint => 'Confirm password';

	/// en: 'Create account'
	String get auth_create_account => 'Create account';

	/// en: 'Email'
	String get auth_email_hint => 'Email';

	/// en: 'Enter your email to receive a verification code'
	String get auth_forgot_subtitle_request => 'Enter your email to receive a verification code';

	/// en: 'Enter the code sent to your email and your new password'
	String get auth_forgot_subtitle_reset => 'Enter the code sent to your email and your new password';

	/// en: 'New password'
	String get auth_new_password_hint => 'New password';

	/// en: 'New password'
	String get auth_new_password_title => 'New password';

	/// en: 'Password'
	String get auth_password_hint => 'Password';

	/// en: 'Medium'
	String get auth_password_medium => 'Medium';

	/// en: 'Password reset successfully'
	String get auth_password_reset_success => 'Password reset successfully';

	/// en: 'Strong'
	String get auth_password_strong => 'Strong';

	/// en: 'Weak'
	String get auth_password_weak => 'Weak';

	/// en: 'Recover password'
	String get auth_recover_password => 'Recover password';

	/// en: 'Resend code'
	String get auth_resend_code => 'Resend code';

	/// en: 'Reset password'
	String get auth_reset_password => 'Reset password';

	/// en: 'Send code'
	String get auth_send_code => 'Send code';

	/// en: 'Sign in'
	String get auth_sign_in => 'Sign in';

	/// en: 'Sign up'
	String get auth_sign_up => 'Sign up';

	/// en: 'Verification code'
	String get auth_verification_code_hint => 'Verification code';

	/// en: 'Completed'
	String get dashboard_completed => 'Completed';

	/// en: 'Dropped'
	String get dashboard_dropped => 'Dropped';

	/// en: 'No series tracked yet. Search and add your first series!'
	String get dashboard_empty => 'No series tracked yet.\nSearch and add your first series!';

	/// en: 'No movies tracked yet. Search and add your first movie!'
	String get dashboard_empty_movies => 'No movies tracked yet.\nSearch and add your first movie!';

	/// en: 'Loading your dashboard...'
	String get dashboard_loading => 'Loading your dashboard...';

	/// en: 'Want to Watch'
	String get dashboard_want_to_watch => 'Want to Watch';

	/// en: 'Watching'
	String get dashboard_watching => 'Watching';

	/// en: 'Network error. Check your connection.'
	String get error_network => 'Network error. Check your connection.';

	/// en: 'Resource not found.'
	String get error_resource_not_found => 'Resource not found.';

	/// en: 'Server error. Please try again later.'
	String get error_server => 'Server error. Please try again later.';

	/// en: 'Session expired. Please log in again.'
	String get error_session_expired => 'Session expired. Please log in again.';

	/// en: 'English'
	String get locale_en_US => 'English';

	/// en: 'Español'
	String get locale_es => 'Español';

	/// en: 'Português'
	String get locale_pt_BR => 'Português';

	/// en: 'Sign in'
	String get login_button => 'Sign in';

	/// en: 'Email'
	String get login_email_hint => 'Email';

	/// en: 'Forgot password?'
	String get login_forgot_password => 'Forgot password?';

	/// en: 'Don't have an account? '
	String get login_no_account => 'Don\'t have an account? ';

	/// en: 'or'
	String get login_or => 'or';

	/// en: 'Password'
	String get login_password_hint => 'Password';

	/// en: 'Sign up'
	String get login_sign_up => 'Sign up';

	/// en: 'Sign in to continue your lists'
	String get login_subtitle => 'Sign in to continue your lists';

	/// en: 'Welcome back'
	String get login_welcome => 'Welcome back';

	/// en: 'Movies'
	String get media_type_movies => 'Movies';

	/// en: 'Series'
	String get media_type_series => 'Series';

	/// en: 'Loading movie details...'
	String get movie_detail_loading => 'Loading movie details...';

	/// en: 'Release Date'
	String get movie_detail_release_date => 'Release Date';

	/// en: 'Runtime'
	String get movie_detail_runtime => 'Runtime';

	/// en: '{minutes} min'
	String get movie_detail_runtime_minutes => '{minutes} min';

	/// en: 'Home'
	String get nav_home => 'Home';

	/// en: 'My Lists'
	String get nav_my_lists => 'My Lists';

	/// en: 'Recommend'
	String get nav_recommend => 'Recommend';

	/// en: 'Search'
	String get nav_search => 'Search';

	/// en: 'Recommendation feature coming soon!'
	String get recommend_coming_soon => 'Recommendation feature coming soon!';

	/// en: 'Recommendation'
	String get recommend_title => 'Recommendation';

	/// en: 'Type at least 2 characters to search'
	String get search_empty => 'Type at least 2 characters to search';

	/// en: 'Search series...'
	String get search_hint => 'Search series...';

	/// en: 'Search movies...'
	String get search_hint_movies => 'Search movies...';

	/// en: 'No series found'
	String get search_no_results => 'No series found';

	/// en: 'No movies found'
	String get search_no_results_movies => 'No movies found';

	/// en: 'Add to List'
	String get series_detail_add_to_list => 'Add to List';

	/// en: 'Cancel'
	String get series_detail_cancel => 'Cancel';

	/// en: 'First Air Date'
	String get series_detail_first_air_date => 'First Air Date';

	/// en: 'Loading series details...'
	String get series_detail_loading => 'Loading series details...';

	/// en: 'Manage Tracking'
	String get series_detail_manage_tracking => 'Manage Tracking';

	/// en: 'Networks'
	String get series_detail_networks => 'Networks';

	/// en: 'No description available.'
	String get series_detail_no_description => 'No description available.';

	/// en: 'Overview'
	String get series_detail_overview => 'Overview';

	/// en: 'Rating'
	String get series_detail_rating => 'Rating';

	/// en: 'Remove'
	String get series_detail_remove => 'Remove';

	/// en: 'Remove "{title}" from your list?'
	String get series_detail_remove_confirm => 'Remove "{title}" from your list?';

	/// en: 'Remove from List'
	String get series_detail_remove_from_list => 'Remove from List';

	/// en: 'Review (optional)'
	String get series_detail_review => 'Review (optional)';

	/// en: 'Save Changes'
	String get series_detail_save_changes => 'Save Changes';

	/// en: '{count} {count, plural, one{season} other{seasons}}'
	String get series_detail_season_count => '{count} {count, plural, one{season} other{seasons}}';

	/// en: 'Seasons'
	String get series_detail_seasons => 'Seasons';

	/// en: 'Show less'
	String get series_detail_show_less => 'Show less';

	/// en: 'Show more'
	String get series_detail_show_more => 'Show more';

	/// en: 'Status'
	String get series_detail_status => 'Status';

	/// en: 'Completed'
	String get tracking_completed => 'Completed';

	/// en: 'Dropped'
	String get tracking_dropped => 'Dropped';

	/// en: 'No {status} series yet'
	String get tracking_empty => 'No {status} series yet';

	/// en: 'No {status} movies yet'
	String get tracking_empty_movies => 'No {status} movies yet';

	/// en: 'My Lists'
	String get tracking_list_title => 'My Lists';

	/// en: 'Want to Watch'
	String get tracking_want_to_watch => 'Want to Watch';

	/// en: 'Watching'
	String get tracking_watching => 'Watching';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app_title' => 'Lorebase',
			'auth_accept_terms' => 'I accept the Terms of Use',
			'auth_already_have_account' => 'Already have an account? ',
			'auth_back_to_login' => 'Back to login',
			'auth_code_sent_success' => 'Code sent to your email',
			'auth_code_sent_to' => 'Enter code sent to {email}',
			'auth_confirmation_code' => 'Confirmation code',
			'auth_confirm_and_login' => 'Confirm & Sign in',
			'auth_confirm_email' => 'Confirm your email',
			'auth_confirm_new_password_hint' => 'Confirm new password',
			'auth_confirm_password_hint' => 'Confirm password',
			'auth_create_account' => 'Create account',
			'auth_email_hint' => 'Email',
			'auth_forgot_subtitle_request' => 'Enter your email to receive a verification code',
			'auth_forgot_subtitle_reset' => 'Enter the code sent to your email and your new password',
			'auth_new_password_hint' => 'New password',
			'auth_new_password_title' => 'New password',
			'auth_password_hint' => 'Password',
			'auth_password_medium' => 'Medium',
			'auth_password_reset_success' => 'Password reset successfully',
			'auth_password_strong' => 'Strong',
			'auth_password_weak' => 'Weak',
			'auth_recover_password' => 'Recover password',
			'auth_resend_code' => 'Resend code',
			'auth_reset_password' => 'Reset password',
			'auth_send_code' => 'Send code',
			'auth_sign_in' => 'Sign in',
			'auth_sign_up' => 'Sign up',
			'auth_verification_code_hint' => 'Verification code',
			'dashboard_completed' => 'Completed',
			'dashboard_dropped' => 'Dropped',
			'dashboard_empty' => 'No series tracked yet.\nSearch and add your first series!',
			'dashboard_empty_movies' => 'No movies tracked yet.\nSearch and add your first movie!',
			'dashboard_loading' => 'Loading your dashboard...',
			'dashboard_want_to_watch' => 'Want to Watch',
			'dashboard_watching' => 'Watching',
			'error_network' => 'Network error. Check your connection.',
			'error_resource_not_found' => 'Resource not found.',
			'error_server' => 'Server error. Please try again later.',
			'error_session_expired' => 'Session expired. Please log in again.',
			'locale_en_US' => 'English',
			'locale_es' => 'Español',
			'locale_pt_BR' => 'Português',
			'login_button' => 'Sign in',
			'login_email_hint' => 'Email',
			'login_forgot_password' => 'Forgot password?',
			'login_no_account' => 'Don\'t have an account? ',
			'login_or' => 'or',
			'login_password_hint' => 'Password',
			'login_sign_up' => 'Sign up',
			'login_subtitle' => 'Sign in to continue your lists',
			'login_welcome' => 'Welcome back',
			'media_type_movies' => 'Movies',
			'media_type_series' => 'Series',
			'movie_detail_loading' => 'Loading movie details...',
			'movie_detail_release_date' => 'Release Date',
			'movie_detail_runtime' => 'Runtime',
			'movie_detail_runtime_minutes' => '{minutes} min',
			'nav_home' => 'Home',
			'nav_my_lists' => 'My Lists',
			'nav_recommend' => 'Recommend',
			'nav_search' => 'Search',
			'recommend_coming_soon' => 'Recommendation feature coming soon!',
			'recommend_title' => 'Recommendation',
			'search_empty' => 'Type at least 2 characters to search',
			'search_hint' => 'Search series...',
			'search_hint_movies' => 'Search movies...',
			'search_no_results' => 'No series found',
			'search_no_results_movies' => 'No movies found',
			'series_detail_add_to_list' => 'Add to List',
			'series_detail_cancel' => 'Cancel',
			'series_detail_first_air_date' => 'First Air Date',
			'series_detail_loading' => 'Loading series details...',
			'series_detail_manage_tracking' => 'Manage Tracking',
			'series_detail_networks' => 'Networks',
			'series_detail_no_description' => 'No description available.',
			'series_detail_overview' => 'Overview',
			'series_detail_rating' => 'Rating',
			'series_detail_remove' => 'Remove',
			'series_detail_remove_confirm' => 'Remove "{title}" from your list?',
			'series_detail_remove_from_list' => 'Remove from List',
			'series_detail_review' => 'Review (optional)',
			'series_detail_save_changes' => 'Save Changes',
			'series_detail_season_count' => '{count} {count, plural, one{season} other{seasons}}',
			'series_detail_seasons' => 'Seasons',
			'series_detail_show_less' => 'Show less',
			'series_detail_show_more' => 'Show more',
			'series_detail_status' => 'Status',
			'tracking_completed' => 'Completed',
			'tracking_dropped' => 'Dropped',
			'tracking_empty' => 'No {status} series yet',
			'tracking_empty_movies' => 'No {status} movies yet',
			'tracking_list_title' => 'My Lists',
			'tracking_want_to_watch' => 'Want to Watch',
			'tracking_watching' => 'Watching',
			_ => null,
		};
	}
}
