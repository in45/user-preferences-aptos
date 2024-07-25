module 0x1::user_preferences {
    use std::error;
    use std::signer;
    use std::string;
    use aptos_framework::event;

    // Resource to store user preferences
    struct PreferencesHolder has key {
        preferences: string::String,
    }

    // Event emitted when preferences are updated
    #[event]
    struct PreferencesChange has drop, store {
        account: address,
        old_preferences: string::String,
        new_preferences: string::String,
    }

    // Constant for no preferences
    const NO_PREFERENCES: u64 = 0;

    // View function to get the current preferences for a given address
    #[view]
    public fun get_preferences(addr: address): string::String acquires PreferencesHolder {
        assert!(exists<PreferencesHolder>(addr), error::not_found(NO_PREFERENCES));
        borrow_global<PreferencesHolder>(addr).preferences
    }

    // Entry function to set preferences for the caller
    public entry fun set_preferences(account: signer, preferences: string::String)
    acquires PreferencesHolder {
        let account_addr = signer::address_of(&account);
        if (!exists<PreferencesHolder>(account_addr)) {
            move_to(&account, PreferencesHolder {
                preferences,
            });
        } else {
            let old_prefs_holder = borrow_global_mut<PreferencesHolder>(account_addr);
            let old_preferences = old_prefs_holder.preferences;
            event::emit(PreferencesChange {
                account: account_addr,
                old_preferences,
                new_preferences: copy preferences,
            });
            old_prefs_holder.preferences = preferences;
        }
    }

    // Test function to verify that the sender can set and retrieve preferences
    #[test(account = @0x1)]
    public entry fun sender_can_set_preferences(account: signer) acquires PreferencesHolder {
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);
        set_preferences(account, string::utf8(b"User Preferences Example"));

        assert!(
            get_preferences(addr) == string::utf8(b"User Preferences Example"),
            NO_PREFERENCES
        );
    }
}
