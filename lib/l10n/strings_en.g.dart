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
class TranslationsEn extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override String get app_title => 'Lorebase';
	@override String get auth_accept_terms => 'I accept the Terms of Use';
	@override String get auth_already_have_account => 'Already have an account? ';
	@override String get auth_back_to_login => 'Back to login';
	@override String get auth_code_sent_success => 'Code sent to your email';
	@override String get auth_code_sent_to => 'Enter code sent to {email}';
	@override String get auth_confirmation_code => 'Confirmation code';
	@override String get auth_confirm_and_login => 'Confirm & Sign in';
	@override String get auth_confirm_email => 'Confirm your email';
	@override String get auth_confirm_new_password_hint => 'Confirm new password';
	@override String get auth_confirm_password_hint => 'Confirm password';
	@override String get auth_create_account => 'Create account';
	@override String get auth_email_hint => 'Email';
	@override String get auth_forgot_subtitle_request => 'Enter your email to receive a verification code';
	@override String get auth_forgot_subtitle_reset => 'Enter the code sent to your email and your new password';
	@override String get auth_new_password_hint => 'New password';
	@override String get auth_new_password_title => 'New password';
	@override String get auth_password_hint => 'Password';
	@override String get auth_password_medium => 'Medium';
	@override String get auth_password_reset_success => 'Password reset successfully';
	@override String get auth_password_strong => 'Strong';
	@override String get auth_password_weak => 'Weak';
	@override String get auth_recover_password => 'Recover password';
	@override String get auth_resend_code => 'Resend code';
	@override String get auth_reset_password => 'Reset password';
	@override String get auth_send_code => 'Send code';
	@override String get auth_sign_in => 'Sign in';
	@override String get auth_sign_up => 'Sign up';
	@override String get auth_verification_code_hint => 'Verification code';
	@override String get dashboard_completed => 'Completed';
	@override String get dashboard_dropped => 'Dropped';
	@override String get dashboard_empty => 'No series tracked yet.\nSearch and add your first series!';
	@override String get dashboard_empty_movies => 'No movies tracked yet.\nSearch and add your first movie!';
	@override String get dashboard_loading => 'Loading your dashboard...';
	@override String get dashboard_want_to_watch => 'Want to Watch';
	@override String get dashboard_watching => 'Watching';
	@override String get error_retry => 'Retry';
	@override String get error_network => 'Network error. Check your connection.';
	@override String get error_resource_not_found => 'Resource not found.';
	@override String get error_server => 'Server error. Please try again later.';
	@override String get error_session_expired => 'Session expired. Please log in again.';
	@override String get locale_en_US => 'English';
	@override String get locale_es => 'Español';
	@override String get locale_pt_BR => 'Português';
	@override String get login_button => 'Sign in';
	@override String get login_email_hint => 'Email';
	@override String get login_forgot_password => 'Forgot password?';
	@override String get login_no_account => 'Don\'t have an account? ';
	@override String get login_or => 'or';
	@override String get login_password_hint => 'Password';
	@override String get login_sign_up => 'Sign up';
	@override String get login_subtitle => 'Sign in to continue your lists';
	@override String get login_welcome => 'Welcome back';
	@override String get media_type_movies => 'Movies';
	@override String get media_type_series => 'Series';
	@override String movie_detail_error({required Object message}) => 'Error: ${message}';
	@override String get movie_detail_loading => 'Loading movie details...';
	@override String get movie_detail_release_date => 'Release Date';
	@override String get movie_detail_runtime => 'Runtime';
	@override String get movie_detail_runtime_minutes => '{minutes} min';
	@override String get nav_home => 'Home';
	@override String get nav_my_lists => 'My Lists';
	@override String get nav_recommend => 'Recommend';
	@override String get nav_social => 'Social';
	@override String get nav_search => 'Search';
	@override String get recommend_coming_soon => 'Recommendation feature coming soon!';
	@override String get search_empty => 'Type at least 2 characters to search';
	@override String get search_hint => 'Search series...';
	@override String get search_hint_movies => 'Search movies...';
	@override String get search_no_results => 'No series found';
	@override String get search_no_results_movies => 'No movies found';
	@override String get series_detail_add_to_list => 'Add to List';
	@override String get series_detail_cancel => 'Cancel';
	@override String get series_detail_episodes => 'Episodes';
	@override String get series_detail_tmdb_rating => 'TMDB Rating';
	@override String series_detail_vote_count({required Object count}) => '${count} votes';
	@override String get series_detail_more_details => 'More details';
	@override String get series_detail_created_by => 'Created by';
	@override String get series_detail_origin_country => 'Origin country';
	@override String get series_detail_type => 'Type';
	@override String get series_detail_popularity => 'Popularity';
	@override String get series_detail_last_episode => 'Last episode';
	@override String get series_detail_next_episode => 'Next episode';
	@override String series_detail_episode_code({required Object season, required Object episode}) => 'S${season}E${episode}';
	@override String get series_detail_episode_date => '{code} · {date}';
	@override String get series_detail_not_available => '—';
	@override String get series_detail_first_air_date => 'First Air Date';
	@override String get series_detail_loading => 'Loading series details...';
	@override String get series_detail_manage_tracking => 'Manage Tracking';
	@override String get series_detail_networks => 'Networks';
	@override String get series_detail_no_description => 'No description available.';
	@override String get series_detail_overview => 'Overview';
	@override String get series_detail_rating => 'Rating';
	@override String get series_detail_remove => 'Remove';
	@override String series_detail_remove_confirm({required Object title}) => 'Remove "${title}" from your list?';
	@override String get series_detail_remove_from_list => 'Remove from List';
	@override String get series_detail_review => 'Review (optional)';
	@override String get series_detail_save_changes => 'Save Changes';
	@override String get series_detail_season_count => '{count} {count, plural, one{season} other{seasons}}';
	@override String get series_detail_seasons => 'Seasons';
	@override String get series_detail_show_less => 'Show less';
	@override String get series_detail_show_more => 'Show more';
	@override String get series_detail_status => 'Status';
	@override String get tracking_completed => 'Completed';
	@override String get tracking_dropped => 'Dropped';
	@override String get tracking_empty => 'No {status} series yet';
	@override String get tracking_empty_movies => 'No {status} movies yet';
	@override String get tracking_want_to_watch => 'Want to Watch';
	@override String get tracking_watching => 'Watching';
	@override String get social_load_error => 'Could not load Social.';
	@override String get social_my_profile => 'My profile →';
	@override String get social_feed_load_error => 'Error loading feed.';
	@override String get social_discover_empty => 'No suggestions for now.';
	@override String get social_follow_error => 'Could not follow this user.';
	@override String get social_try_again => 'Try again';
	@override String get social_display_name => 'Display name';
	@override String get social_avatar_url => 'Avatar URL';
	@override String get social_privacy => 'Privacy';
	@override String get social_public => 'Public';
	@override String get social_private => 'Private';
	@override String get social_save_profile => 'Save profile';
	@override String get social_finish => 'Finish';
	@override String get social_discover_people_cta => 'Discover people';
	@override String get social_edit_profile => 'Edit profile';
	@override String get social_public_profile => 'Public profile';
	@override String get social_save_changes => 'Save changes';
	@override String get social_profile_load_error => 'Could not load your social profile.';
	@override String get social_profile_save_error => 'Could not save profile. Please try again.';
	@override String get social_empty_people => 'No people to show.';
	@override String get social_list_load_error => 'Error loading list.';
	@override String get social_activity => 'Activity';
	@override String get social_lists => 'Lists';
	@override String get social_followers => 'Followers';
	@override String get social_following => 'Following';
	@override String get social_profile_unavailable => 'This profile is not available right now.';
	@override String get social_empty_public_activity => 'No public activity yet.';
	@override String social_section_load_error({required Object section}) => 'Could not load ${section}.';
	@override String social_section_loading({required Object section}) => 'Loading ${section}...';
	@override String social_followers_count({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count,
		one: '${count} follower',
		other: '${count} followers',
	);
	@override String social_following_count({required Object count}) => '${count} following';
	@override String social_affinity({required Object percent}) => '${percent}% affinity';
	@override String get social_follow => 'Follow';
	@override String get social_unfollow => 'Unfollow';
	@override String get social_follow_updating_semantics => 'Updating follow status';
	@override String get social_following_action => 'Following';
	@override String get social_following_user_semantics => 'Following user';
	@override String get social_feed => 'Feed';
	@override String get social_discover => 'Discover';
	@override String get social_empty_feed_title => 'Your feed is empty';
	@override String get social_empty_feed_body => 'Follow people to see their activity here.';
	@override String get social_discover_people => 'Discover people';
	@override String get social_create_profile_title => 'Create your social profile';
	@override String get social_display_name_required => 'Enter a display name';
	@override String get social_privacy_required => 'Choose profile privacy';
	@override String get social_follow_suggestions => 'Suggestions to follow';
	@override String get social_discover_timeout => 'Discover took too long to respond. Please try again shortly.';
	@override String get social_discover_error => 'Error discovering people.';
	@override String get social_edit_profile_title => 'Edit social profile';
	@override String get social_public_lists_title => 'Public lists';
	@override String get social_status_plan_to_watch => 'Want to watch';
	@override String get social_status_watching => 'Watching';
	@override String get social_status_completed => 'Completed';
	@override String get social_status_dropped => 'Dropped';
	@override String social_public_list_empty({required Object section}) => 'No items in ${section}.';
	@override String get dashboard_social_preview_title => 'Social activity';
	@override String get dashboard_social_preview_body => 'See what other fans are watching and rating.';
	@override String get dashboard_social_preview_cta => 'Open Social';
	@override String get dashboard_recommendation_title => 'Recommendations for you';
	@override String get dashboard_recommendation_body => 'Find something tailored to watch next.';
	@override String get dashboard_recommendation_cta => 'Get recommendations';
	@override String get nav_change_language_tooltip => 'Change language';
	@override String get nav_sign_out_tooltip => 'Sign out';
	@override String get search_clear_tooltip => 'Clear search';
	@override String get auth_resend_confirmation_code => 'Resend confirmation code';
	@override String get social_public_list_empty_default => 'No public items yet.';
	@override String social_open_media_semantics({required Object title}) => 'Open ${title}';
	@override String get social_media_type_movie => 'Movie';
	@override String get social_media_type_series => 'Series';
	@override String dashboard_social_profile_label({required Object name}) => 'Social profile: ${name}';
	@override String get social_activity_rated => 'rated';
	@override String get social_activity_reviewed => 'wrote a review of';
	@override String get social_activity_completed => 'completed';
	@override String get social_activity_started_watching => 'started';
	@override String get social_activity_dropped => 'dropped';
	@override String get social_activity_added_to_list => 'added to list';
	@override String get social_activity_interacted_with => 'interacted with';
	@override String get auth_error_email_password_required => 'Enter email and password';
	@override String get auth_error_invalid_credentials => 'Incorrect email or password';
	@override String get auth_error_email_required => 'Enter your email';
	@override String get auth_error_send_code => 'Error sending code. Try again.';
	@override String get auth_error_passwords_do_not_match => 'Passwords do not match';
	@override String get auth_error_fill_all_fields => 'Fill in all fields';
	@override String get auth_error_reset_password => 'Error resetting password. Try again.';
	@override String get auth_error_password_too_weak => 'Password is too weak';
	@override String get auth_error_accept_terms => 'Accept the terms of use';
	@override String get auth_error_email_already_registered => 'This email is already registered. Sign in or use another email.';
	@override String get auth_error_create_account => 'Error creating account. Try again.';
	@override String get auth_error_confirmation_code_required => 'Enter the confirmation code';
	@override String get auth_error_invalid_code => 'Invalid code. Try again.';
	@override String get auth_error_resend_code => 'Could not resend the code. Try again.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
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
			'error_retry' => 'Retry',
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
			'movie_detail_error' => ({required Object message}) => 'Error: ${message}',
			'movie_detail_loading' => 'Loading movie details...',
			'movie_detail_release_date' => 'Release Date',
			'movie_detail_runtime' => 'Runtime',
			'movie_detail_runtime_minutes' => '{minutes} min',
			'nav_home' => 'Home',
			'nav_my_lists' => 'My Lists',
			'nav_recommend' => 'Recommend',
			'nav_social' => 'Social',
			'nav_search' => 'Search',
			'recommend_coming_soon' => 'Recommendation feature coming soon!',
			'search_empty' => 'Type at least 2 characters to search',
			'search_hint' => 'Search series...',
			'search_hint_movies' => 'Search movies...',
			'search_no_results' => 'No series found',
			'search_no_results_movies' => 'No movies found',
			'series_detail_add_to_list' => 'Add to List',
			'series_detail_cancel' => 'Cancel',
			'series_detail_episodes' => 'Episodes',
			'series_detail_tmdb_rating' => 'TMDB Rating',
			'series_detail_vote_count' => ({required Object count}) => '${count} votes',
			'series_detail_more_details' => 'More details',
			'series_detail_created_by' => 'Created by',
			'series_detail_origin_country' => 'Origin country',
			'series_detail_type' => 'Type',
			'series_detail_popularity' => 'Popularity',
			'series_detail_last_episode' => 'Last episode',
			'series_detail_next_episode' => 'Next episode',
			'series_detail_episode_code' => ({required Object season, required Object episode}) => 'S${season}E${episode}',
			'series_detail_episode_date' => '{code} · {date}',
			'series_detail_not_available' => '—',
			'series_detail_first_air_date' => 'First Air Date',
			'series_detail_loading' => 'Loading series details...',
			'series_detail_manage_tracking' => 'Manage Tracking',
			'series_detail_networks' => 'Networks',
			'series_detail_no_description' => 'No description available.',
			'series_detail_overview' => 'Overview',
			'series_detail_rating' => 'Rating',
			'series_detail_remove' => 'Remove',
			'series_detail_remove_confirm' => ({required Object title}) => 'Remove "${title}" from your list?',
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
			'tracking_want_to_watch' => 'Want to Watch',
			'tracking_watching' => 'Watching',
			'social_load_error' => 'Could not load Social.',
			'social_my_profile' => 'My profile →',
			'social_feed_load_error' => 'Error loading feed.',
			'social_discover_empty' => 'No suggestions for now.',
			'social_follow_error' => 'Could not follow this user.',
			'social_try_again' => 'Try again',
			'social_display_name' => 'Display name',
			'social_avatar_url' => 'Avatar URL',
			'social_privacy' => 'Privacy',
			'social_public' => 'Public',
			'social_private' => 'Private',
			'social_save_profile' => 'Save profile',
			'social_finish' => 'Finish',
			'social_discover_people_cta' => 'Discover people',
			'social_edit_profile' => 'Edit profile',
			'social_public_profile' => 'Public profile',
			'social_save_changes' => 'Save changes',
			'social_profile_load_error' => 'Could not load your social profile.',
			'social_profile_save_error' => 'Could not save profile. Please try again.',
			'social_empty_people' => 'No people to show.',
			'social_list_load_error' => 'Error loading list.',
			'social_activity' => 'Activity',
			'social_lists' => 'Lists',
			'social_followers' => 'Followers',
			'social_following' => 'Following',
			'social_profile_unavailable' => 'This profile is not available right now.',
			'social_empty_public_activity' => 'No public activity yet.',
			'social_section_load_error' => ({required Object section}) => 'Could not load ${section}.',
			'social_section_loading' => ({required Object section}) => 'Loading ${section}...',
			'social_followers_count' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count, one: '${count} follower', other: '${count} followers', ), 
			'social_following_count' => ({required Object count}) => '${count} following',
			'social_affinity' => ({required Object percent}) => '${percent}% affinity',
			'social_follow' => 'Follow',
			'social_unfollow' => 'Unfollow',
			'social_follow_updating_semantics' => 'Updating follow status',
			'social_following_action' => 'Following',
			'social_following_user_semantics' => 'Following user',
			'social_feed' => 'Feed',
			'social_discover' => 'Discover',
			'social_empty_feed_title' => 'Your feed is empty',
			'social_empty_feed_body' => 'Follow people to see their activity here.',
			'social_discover_people' => 'Discover people',
			'social_create_profile_title' => 'Create your social profile',
			'social_display_name_required' => 'Enter a display name',
			'social_privacy_required' => 'Choose profile privacy',
			'social_follow_suggestions' => 'Suggestions to follow',
			'social_discover_timeout' => 'Discover took too long to respond. Please try again shortly.',
			'social_discover_error' => 'Error discovering people.',
			'social_edit_profile_title' => 'Edit social profile',
			'social_public_lists_title' => 'Public lists',
			'social_status_plan_to_watch' => 'Want to watch',
			'social_status_watching' => 'Watching',
			'social_status_completed' => 'Completed',
			'social_status_dropped' => 'Dropped',
			'social_public_list_empty' => ({required Object section}) => 'No items in ${section}.',
			'dashboard_social_preview_title' => 'Social activity',
			'dashboard_social_preview_body' => 'See what other fans are watching and rating.',
			'dashboard_social_preview_cta' => 'Open Social',
			'dashboard_recommendation_title' => 'Recommendations for you',
			'dashboard_recommendation_body' => 'Find something tailored to watch next.',
			'dashboard_recommendation_cta' => 'Get recommendations',
			'nav_change_language_tooltip' => 'Change language',
			'nav_sign_out_tooltip' => 'Sign out',
			'search_clear_tooltip' => 'Clear search',
			'auth_resend_confirmation_code' => 'Resend confirmation code',
			'social_public_list_empty_default' => 'No public items yet.',
			'social_open_media_semantics' => ({required Object title}) => 'Open ${title}',
			'social_media_type_movie' => 'Movie',
			'social_media_type_series' => 'Series',
			'dashboard_social_profile_label' => ({required Object name}) => 'Social profile: ${name}',
			'social_activity_rated' => 'rated',
			'social_activity_reviewed' => 'wrote a review of',
			'social_activity_completed' => 'completed',
			'social_activity_started_watching' => 'started',
			'social_activity_dropped' => 'dropped',
			'social_activity_added_to_list' => 'added to list',
			'social_activity_interacted_with' => 'interacted with',
			'auth_error_email_password_required' => 'Enter email and password',
			'auth_error_invalid_credentials' => 'Incorrect email or password',
			'auth_error_email_required' => 'Enter your email',
			'auth_error_send_code' => 'Error sending code. Try again.',
			'auth_error_passwords_do_not_match' => 'Passwords do not match',
			'auth_error_fill_all_fields' => 'Fill in all fields',
			'auth_error_reset_password' => 'Error resetting password. Try again.',
			'auth_error_password_too_weak' => 'Password is too weak',
			'auth_error_accept_terms' => 'Accept the terms of use',
			'auth_error_email_already_registered' => 'This email is already registered. Sign in or use another email.',
			'auth_error_create_account' => 'Error creating account. Try again.',
			'auth_error_confirmation_code_required' => 'Enter the confirmation code',
			'auth_error_invalid_code' => 'Invalid code. Try again.',
			'auth_error_resend_code' => 'Could not resend the code. Try again.',
			_ => null,
		};
	}
}
