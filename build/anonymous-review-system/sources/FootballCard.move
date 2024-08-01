module 0x1::FootballCard {
    use std::signer;
    use std::debug;

    // Error codes
    const STAR_ALREADY_EXISTS: u64 = 100;
    const STAR_NOT_EXISTS: u64 = 101;

    // Struct definition
    struct FootballStar has key, drop {
        name: vector<u8>,
        country: vector<u8>,
        position: u8,
        value: u64,
    }

    // Function to create a new FootballStar
    public fun create_star(
        name: vector<u8>,
        country: vector<u8>,
        position: u8
    ): FootballStar {
        FootballStar {
            name,
            country,
            position,
            value: 0,
        }
    }

    // Function to mint a new FootballStar to an account
    public fun mint_star(to: &signer, star: FootballStar) {
        let acc_addr = signer::address_of(to);
        assert!(!star_exists(acc_addr), STAR_ALREADY_EXISTS);
        move_to<FootballStar>(to, star);
    }

    // Function to get the name and value of a FootballStar
    public fun get_star(owner: &signer): (vector<u8>, u64) acquires FootballStar {
        let acc_addr = signer::address_of(owner);
        let star = borrow_global_mut<FootballStar>(acc_addr);
        (star.name, star.value)
    }

    // Function to check if a FootballStar exists for an account
    public fun star_exists(acc: address): bool {
        exists<FootballStar>(acc)
    }

    // Function to set the price of a FootballStar
    public fun set_star_price(owner: &signer, price: u64) acquires FootballStar {
        let acc_addr = signer::address_of(owner);
        assert!(star_exists(acc_addr), STAR_NOT_EXISTS);
        let star = borrow_global_mut<FootballStar>(acc_addr);
        star.value = price;
    }

    // Function to transfer a FootballStar to another account
    public fun transfer_star(owner: &signer, to: &signer) acquires FootballStar {
        let acc_addr = signer::address_of(owner);
        assert!(star_exists(acc_addr), STAR_NOT_EXISTS);
        let star = move_from<FootballStar>(acc_addr);
        let acc_addr2 = signer::address_of(to);
        move_to<FootballStar>(to, star);
        assert!(star_exists(acc_addr2), STAR_ALREADY_EXISTS);
    }

    #[test(owner = @0x123, to = @0x768)]
    fun test_football_star(owner: signer, to: signer) acquires FootballStar {
        // Create a FootballStar
        let star = create_star(b"Sunil Chhetri", b"India", 2);
        mint_star(&owner, star);
        let (name, value) = get_star(&owner);
        debug::print(&name);
        debug::print(&value);
        set_star_price(&owner, 100);
        transfer_star(&owner, &to);
        let (name, value) = get_star(&to);
        debug::print(&name);
        debug::print(&value);
    }
}
