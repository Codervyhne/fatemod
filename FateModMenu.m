//
//  FateModMenu.m
//  Fate Mod - Modern iOS Mod Menu
//
//  Created for Animal Company
//  Version 1.0
//

#import "FateModMenu.h"
#import <dlfcn.h>

@implementation FateModMenu

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    self.currentTab = 0;
    self.spawnQuantity = 1;
    self.customY = 3.0;
    
    [self initializeData];
    [self loadSettings];
    [self setupUI];
    
    // Initialize game integration on background thread (optional)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            if ([self initializeIL2CPP]) {
                [self initializeGameClasses];
                NSLog(@"[Fate] Game integration initialized");
            } else {
                NSLog(@"[Fate] Game integration not available - menu will work in basic mode");
            }
        } @catch (NSException *exception) {
            NSLog(@"[Fate] Exception during initialization: %@", exception);
        }
    });
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateLayoutForOrientation];
}

#pragma mark - Data Initialization

- (void)initializeData {
    // All 313 items from Animal Company
    self.availableItems = @[
        @"item_ac_cola", @"item_alphablade", @"item_anti_gravity_grenade",
        @"item_apple", @"item_arena_pistol", @"item_arena_shotgun",
        @"item_arrow", @"item_arrow_bomb", @"item_arrow_heart",
        @"item_arrow_lightbulb", @"item_arrow_teleport", @"item_axe",
        @"item_backpack", @"item_backpack_black", @"item_backpack_green",
        @"item_backpack_large_base", @"item_backpack_large_basketball", @"item_backpack_large_clover",
        @"item_backpack_pink", @"item_backpack_realistic", @"item_backpack_small_base",
        @"item_backpack_white", @"item_backpack_with_flashlight", @"item_balloon",
        @"item_balloon_heart", @"item_banana", @"item_banana_chips",
        @"item_baseball_bat", @"item_basic_fishing_rod", @"item_beans",
        @"item_big_cup", @"item_bighead_larva", @"item_bloodlust_vial",
        @"item_boombox", @"item_boombox_neon", @"item_boomerang",
        @"item_box_fan", @"item_brain_chunk", @"item_brick",
        @"item_broccoli_grenade", @"item_broccoli_shrink_grenade", @"item_broom",
        @"item_broom_halloween", @"item_burrito", @"item_calculator",
        @"item_cardboard_box", @"item_ceo_plaque", @"item_clapper",
        @"item_cluster_grenade", @"item_coconut_shell", @"item_cola",
        @"item_cola_large", @"item_company_ration", @"item_company_ration_heal",
        @"item_cracker", @"item_crate", @"item_crossbow",
        @"item_crossbow_heart", @"item_crowbar", @"item_cutie_dead",
        @"item_d20", @"item_demon_sword", @"item_disc",
        @"item_disposable_camera", @"item_drill", @"item_drill_neon",
        @"item_dynamite", @"item_dynamite_cube", @"item_egg",
        @"item_electrical_tape", @"item_eraser", @"item_film_reel",
        @"item_finger_board", @"item_fish_dumb_fish", @"item_flamethrower",
        @"item_flamethrower_skull", @"item_flamethrower_skull_ruby", @"item_flaregun",
        @"item_flashbang", @"item_flashlight", @"item_flashlight_mega",
        @"item_flashlight_red", @"item_flipflop_realistic", @"item_floppy3",
        @"item_floppy5", @"item_football", @"item_friend_launcher",
        @"item_frying_pan", @"item_gameboy", @"item_glowstick",
        @"item_goldbar", @"item_goldcoin", @"item_goop",
        @"item_goopfish", @"item_great_sword", @"item_grenade",
        @"item_grenade_gold", @"item_grenade_launcher", @"item_guided_boomerang",
        @"item_harddrive", @"item_hatchet", @"item_hawaiian_drum",
        @"item_heart_chunk", @"item_heart_gun", @"item_heartchocolatebox",
        @"item_hh_key", @"item_hookshot", @"item_hookshot_sword",
        @"item_hot_cocoa", @"item_hoverpad", @"item_impulse_grenade",
        @"item_jetpack", @"item_joystick", @"item_joystick_inv_y",
        @"item_keycard", @"item_lance", @"item_landmine",
        @"item_large_banana", @"item_megaphone", @"item_metal_ball",
        @"item_metal_ball_xmas", @"item_metal_plate", @"item_metal_plate_xmas",
        @"item_metal_rod", @"item_metal_rod_xmas", @"item_metal_triangle",
        @"item_momboss_box", @"item_moneygun", @"item_motor",
        @"item_mountain_key", @"item_mug", @"item_needle",
        @"item_nut", @"item_nut_drop", @"item_ogre_hands",
        @"item_ore_copper_l", @"item_ore_copper_m", @"item_ore_copper_s",
        @"item_ore_gold_l", @"item_ore_gold_m", @"item_ore_gold_s",
        @"item_ore_hell", @"item_ore_silver_l", @"item_ore_silver_m",
        @"item_ore_silver_s", @"item_painting_canvas", @"item_paperpack",
        @"item_pelican_case", @"item_pickaxe", @"item_pickaxe_cny",
        @"item_pickaxe_cube", @"item_pickaxe_realistic", @"item_pinata_bat",
        @"item_pineapple", @"item_pipe", @"item_pistol_dragon",
        @"item_piston", @"item_plank", @"item_plunger",
        @"item_pogostick", @"item_police_baton", @"item_popcorn",
        @"item_portable_teleporter", @"item_prop_scanner", @"item_pumpkin_bomb",
        @"item_pumpkin_pie", @"item_pumpkinjack", @"item_pumpkinjack_small",
        @"item_quest_gy_skull", @"item_quest_gy_skull_special", @"item_quest_hlal_brain",
        @"item_quest_hlal_eyeball", @"item_quest_hlal_flesh", @"item_quest_hlal_heart",
        @"item_quest_key_graveyard", @"item_quest_vhs", @"item_quest_vhs_backlots",
        @"item_quest_vhs_basement", @"item_quest_vhs_cave", @"item_quest_vhs_circus_day",
        @"item_quest_vhs_circus_ext", @"item_quest_vhs_circus_fac", @"item_quest_vhs_dam_facility",
        @"item_quest_vhs_dam_servers", @"item_quest_vhs_dark_forest", @"item_quest_vhs_forest",
        @"item_quest_vhs_foundation", @"item_quest_vhs_graveyard", @"item_quest_vhs_haunted_house",
        @"item_quest_vhs_hell", @"item_quest_vhs_lab", @"item_quest_vhs_lake",
        @"item_quest_vhs_lobby", @"item_quest_vhs_mines", @"item_quest_vhs_mountain",
        @"item_quest_vhs_mountainbot", @"item_quest_vhs_mountainshack", @"item_quest_vhs_mountainvault",
        @"item_quest_vhs_office", @"item_quest_vhs_office_basement", @"item_quest_vhs_powerplant_microwave",
        @"item_quest_vhs_powerplant_reactorcore", @"item_quest_vhs_powerplant_security", @"item_quest_vhs_powerplant_supportfacility",
        @"item_quest_vhs_sewers", @"item_quiver", @"item_quiver_heart",
        @"item_radiation_gun", @"item_radioactive_broccoli", @"item_randombox_base",
        @"item_randombox_mobloot_big", @"item_randombox_mobloot_medium", @"item_randombox_mobloot_small",
        @"item_randombox_mobloot_weapons", @"item_randombox_mobloot_zombie", @"item_rare_card",
        @"item_remote_controller", @"item_revolver", @"item_revolver_ammo",
        @"item_revolver_gold", @"item_ring_buoy", @"item_robo_monke",
        @"item_robot_arm_left", @"item_robot_arm_right", @"item_robot_head",
        @"item_rope", @"item_rpg", @"item_rpg_ammo",
        @"item_rpg_ammo_egg", @"item_rpg_ammo_spear", @"item_rpg_cny",
        @"item_rpg_easter", @"item_rpg_smshr", @"item_rpg_spear",
        @"item_rubberducky", @"item_ruby", @"item_saddle",
        @"item_scanner", @"item_scissors", @"item_server_pad",
        @"item_shield", @"item_shield_bones", @"item_shield_police",
        @"item_shield_viking_1", @"item_shield_viking_2", @"item_shield_viking_3",
        @"item_shield_viking_4", @"item_shotgun", @"item_shotgun_ammo",
        @"item_shotgun_viper", @"item_shovel", @"item_shredder",
        @"item_shrinking_broccoli", @"item_skipole", @"item_skishoe",
        @"item_skishoe_2", @"item_skishoe_3", @"item_skishoe_4",
        @"item_sludge", @"item_snail_friend", @"item_snowball",
        @"item_snowboard", @"item_snowboard_2", @"item_snowboard_3",
        @"item_snowboard_4", @"item_snowboard_auto", @"item_stapler",
        @"item_stash_grenade", @"item_steel_beam", @"item_steel_beam_xmas",
        @"item_stellarsword_blue", @"item_stellarsword_gold", @"item_stick_armbones",
        @"item_stick_bone", @"item_sticker_dispenser", @"item_sticky_dynamite",
        @"item_stinky_cheese", @"item_tablet", @"item_tapedispenser",
        @"item_tele_grenade", @"item_teleport_gun", @"item_theremin",
        @"item_timebomb", @"item_toilet_paper", @"item_toilet_paper_mega",
        @"item_toilet_paper_roll_empty", @"item_token_circus", @"item_trampoline",
        @"item_treestick", @"item_tripwire_explosive", @"item_trophy",
        @"item_truss", @"item_truss_xmas", @"item_turkey_leg",
        @"item_turkey_whole", @"item_ukulele", @"item_ukulele_gold",
        @"item_umbrella", @"item_umbrella_clover", @"item_umbrella_squirrel",
        @"item_upsidedown_loot", @"item_uranium_chunk_l", @"item_uranium_chunk_m",
        @"item_uranium_chunk_s", @"item_viking_hammer", @"item_viking_hammer_twilight",
        @"item_wheelhandle", @"item_wheelhandle_big", @"item_whoopie",
        @"item_wood_log", @"item_wood_pallet", @"item_zipline_gun",
        @"item_zombie_meat"
    ];
    
    // Preset spawn locations
    self.presetLocations = @[
        @"Player Position",
        @"Spawn Point",
        @"Office Main",
        @"Factory Floor",
        @"Mountain Base",
        @"Cave Entrance",
        @"Lake Shore",
        @"Forest Path",
        @"Graveyard",
        @"Circus Tent",
        @"Dam Facility",
        @"Underground Lab"
    ];
}

#pragma mark - IL2CPP Initialization

- (BOOL)initializeIL2CPP {
    void *handle = dlopen(NULL, RTLD_NOW);
    if (!handle) return NO;
    
    // Load IL2CPP functions
    self.il2cpp_class_from_name = dlsym(handle, "il2cpp_class_from_name");
    self.il2cpp_class_get_method_from_name = dlsym(handle, "il2cpp_class_get_method_from_name");
    self.il2cpp_runtime_invoke = dlsym(handle, "il2cpp_runtime_invoke");
    self.il2cpp_string_new = dlsym(handle, "il2cpp_string_new");
    self.il2cpp_class_get_field_from_name = dlsym(handle, "il2cpp_class_get_field_from_name");
    self.il2cpp_field_set_value = dlsym(handle, "il2cpp_field_set_value");
    
    if (!self.il2cpp_class_from_name || !self.il2cpp_runtime_invoke) {
        NSLog(@"[Fate] Failed to load IL2CPP functions");
        return NO;
    }
    
    NSLog(@"[Fate] IL2CPP initialized successfully");
    return YES;
}

- (BOOL)initializeGameClasses {
    self.gameImage = [self getGameImage:"AnimalCompany.dll"];
    if (!self.gameImage) {
        NSLog(@"[Fate] Failed to get game image");
        return NO;
    }
    
    // Get game classes
    self.netPlayerClass = self.il2cpp_class_from_name(self.gameImage, "AnimalCompany", "NetPlayer");
    self.prefabGeneratorClass = self.il2cpp_class_from_name(self.gameImage, "AnimalCompany", "PrefabGenerator");
    self.gameManagerClass = self.il2cpp_class_from_name(self.gameImage, "AnimalCompany", "GameManager");
    
    if (!self.netPlayerClass) {
        NSLog(@"[Fate] Failed to get NetPlayer class");
        return NO;
    }
    
    // Get methods
    self.getLocalPlayerMethod = self.il2cpp_class_get_method_from_name(self.netPlayerClass, "get_localPlayer", 0);
    self.addMoneyMethod = self.il2cpp_class_get_method_from_name(self.netPlayerClass, "AddPlayerMoney", 1);
    
    if (self.prefabGeneratorClass) {
        self.spawnItemMethod = self.il2cpp_class_get_method_from_name(self.prefabGeneratorClass, "SpawnItem", 4);
    }
    
    NSLog(@"[Fate] Game classes initialized successfully");
    return YES;
}

- (void *)getGameImage:(const char *)imageName {
    void *(*il2cpp_domain_get)() = dlsym(RTLD_DEFAULT, "il2cpp_domain_get");
    void *(*il2cpp_domain_get_assemblies)(void *, size_t *) = dlsym(RTLD_DEFAULT, "il2cpp_domain_get_assemblies");
    void *(*il2cpp_assembly_get_image)(void *) = dlsym(RTLD_DEFAULT, "il2cpp_assembly_get_image");
    const char *(*il2cpp_image_get_name)(void *) = dlsym(RTLD_DEFAULT, "il2cpp_image_get_name");
    
    if (!il2cpp_domain_get || !il2cpp_domain_get_assemblies) return NULL;
    
    void *domain = il2cpp_domain_get();
    size_t assemblyCount = 0;
    void **assemblies = il2cpp_domain_get_assemblies(domain, &assemblyCount);
    
    for (size_t i = 0; i < assemblyCount; i++) {
        void *image = il2cpp_assembly_get_image(assemblies[i]);
        const char *name = il2cpp_image_get_name(image);
        if (name && strcmp(name, imageName) == 0) {
            return image;
        }
    }
    
    return NULL;
}

- (void *)getLocalPlayer {
    if (!self.getLocalPlayerMethod) return NULL;
    
    void *exception = NULL;
    void *player = self.il2cpp_runtime_invoke(self.getLocalPlayerMethod, NULL, NULL, &exception);
    
    if (exception) {
        NSLog(@"[Fate] Exception getting local player");
        return NULL;
    }
    
    return player;
}

#pragma mark - UI Setup

- (void)setupUI {
    CGRect bounds = self.view.bounds;
    CGFloat width = MIN(bounds.size.width * 0.9, 400);
    CGFloat height = MIN(bounds.size.height * 0.8, 650);
    
    // Container with modern styling
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(
        (bounds.size.width - width) / 2,
        (bounds.size.height - height) / 2,
        width, height
    )];
    self.containerView.backgroundColor = [UIColor colorWithRed:0.08 green:0.09 blue:0.11 alpha:1.0];
    self.containerView.layer.cornerRadius = 20;
    self.containerView.layer.masksToBounds = NO;
    
    // Modern gradient overlay
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.containerView.bounds;
    self.gradientLayer.colors = @[
        (id)[UIColor colorWithRed:0.15 green:0.18 blue:0.25 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.10 green:0.12 blue:0.18 alpha:1.0].CGColor
    ];
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(1, 1);
    self.gradientLayer.cornerRadius = 20;
    [self.containerView.layer insertSublayer:self.gradientLayer atIndex:0];
    
    // Border with glow effect
    self.containerView.layer.borderWidth = 2;
    self.containerView.layer.borderColor = [UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:0.5].CGColor;
    self.containerView.layer.shadowColor = [UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:1.0].CGColor;
    self.containerView.layer.shadowRadius = 15;
    self.containerView.layer.shadowOpacity = 0.5;
    self.containerView.layer.shadowOffset = CGSizeMake(0, 0);
    
    [self.view addSubview:self.containerView];
    
    // Title label with icon
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, width - 100, 40)];
    titleLabel.text = @"⚡ FATE";
    titleLabel.textColor = [UIColor colorWithRed:0.5 green:0.8 blue:1.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightHeavy];
    [self.containerView addSubview:titleLabel];
    
    // Close button with modern style
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(width - 48, 20, 36, 36);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    closeBtn.tintColor = [UIColor whiteColor];
    closeBtn.backgroundColor = [UIColor colorWithRed:0.8 green:0.2 blue:0.3 alpha:0.8];
    closeBtn.layer.cornerRadius = 18;
    [closeBtn addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:closeBtn];
    
    // Tab control with modern styling
    self.tabControl = [[UISegmentedControl alloc] initWithItems:@[@"📦 Items", @"⚙️ Settings"]];
    self.tabControl.frame = CGRectMake(15, 65, width - 30, 36);
    self.tabControl.selectedSegmentIndex = self.currentTab;
    self.tabControl.backgroundColor = [UIColor colorWithRed:0.12 green:0.14 blue:0.18 alpha:1.0];
    self.tabControl.selectedSegmentTintColor = [UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:1.0];
    
    NSDictionary *normalAttrs = @{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.7 alpha:1.0]};
    NSDictionary *selectedAttrs = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    [self.tabControl setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    [self.tabControl setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    
    [self.tabControl addTarget:self action:@selector(tabChanged:) forControlEvents:UIControlEventValueChanged];
    [self.containerView addSubview:self.tabControl];
    
    // Content scroll view
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 115, width - 20, height - 125)];
    self.contentScrollView.backgroundColor = [UIColor colorWithRed:0.09 green:0.10 blue:0.13 alpha:0.8];
    self.contentScrollView.layer.cornerRadius = 12;
    self.contentScrollView.showsVerticalScrollIndicator = YES;
    self.contentScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.containerView addSubview:self.contentScrollView];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width - 20, 800)];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentScrollView addSubview:self.contentView];
    
    [self loadCurrentTab];
}

- (void)updateLayoutForOrientation {
    CGRect bounds = self.view.bounds;
    CGFloat width = bounds.size.width > bounds.size.height ? 
                    MIN(bounds.size.width * 0.7, 600) : 
                    MIN(bounds.size.width * 0.9, 380);
    CGFloat height = bounds.size.width > bounds.size.height ?
                     MIN(bounds.size.height * 0.85, 480) :
                     MIN(bounds.size.height * 0.7, 580);
    
    self.containerView.frame = CGRectMake(
        (bounds.size.width - width) / 2,
        (bounds.size.height - height) / 2,
        width, height
    );
    
    if (self.gradientLayer) {
        self.gradientLayer.frame = self.containerView.bounds;
    }
    
    [self loadCurrentTab];
}

#pragma mark - Tab Management

- (void)tabChanged:(UISegmentedControl *)sender {
    self.currentTab = sender.selectedSegmentIndex;
    [self saveSettings];
    [self loadCurrentTab];
}

- (void)loadCurrentTab {
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    if (self.currentTab == 0) {
        [self loadItemsTab];
    } else {
        [self loadSettingsTab];
    }
}

#pragma mark - Items Tab

- (void)loadItemsTab {
    CGFloat width = self.contentView.bounds.size.width - 24;
    CGFloat yPos = 15;
    
    // Item spawner section
    UIView *itemSection = [self createSectionWithTitle:@"Item Spawner" 
                                                 frame:CGRectMake(12, yPos, width, 400)
                                                 color:[UIColor colorWithRed:0.15 green:0.18 blue:0.22 alpha:1.0]];
    [self.contentView addSubview:itemSection];
    
    // Search field
    self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, width - 24, 40)];
    self.searchField.placeholder = @"Search items...";
    self.searchField.backgroundColor = [UIColor colorWithRed:0.18 green:0.20 blue:0.24 alpha:1.0];
    self.searchField.textColor = [UIColor whiteColor];
    self.searchField.layer.cornerRadius = 8;
    self.searchField.textAlignment = NSTextAlignmentCenter;
    self.searchField.delegate = self;
    [self.searchField addTarget:self action:@selector(searchItems:) forControlEvents:UIControlEventEditingChanged];
    
    // Placeholder styling
    NSAttributedString *placeholder = [[NSAttributedString alloc] 
        initWithString:@"🔍 Search items..."
        attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1.0]}];
    self.searchField.attributedPlaceholder = placeholder;
    
    [itemSection addSubview:self.searchField];
    
    // Item picker
    self.itemPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(12, 90, width - 24, 180)];
    self.itemPicker.delegate = self;
    self.itemPicker.dataSource = self;
    self.itemPicker.backgroundColor = [UIColor colorWithRed:0.14 green:0.16 blue:0.19 alpha:1.0];
    self.itemPicker.layer.cornerRadius = 8;
    [itemSection addSubview:self.itemPicker];
    
    if (self.selectedItemIndex < self.availableItems.count) {
        [self.itemPicker selectRow:self.selectedItemIndex inComponent:0 animated:NO];
    }
    
    // Quantity controls
    UILabel *qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 285, 100, 28)];
    qtyLabel.text = @"Quantity:";
    qtyLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    qtyLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [itemSection addSubview:qtyLabel];
    
    self.quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 285, 60, 28)];
    self.quantityLabel.text = [NSString stringWithFormat:@"%ld", (long)self.spawnQuantity];
    self.quantityLabel.textColor = [UIColor colorWithRed:0.5 green:0.8 blue:1.0 alpha:1.0];
    self.quantityLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    self.quantityLabel.textAlignment = NSTextAlignmentCenter;
    [itemSection addSubview:self.quantityLabel];
    
    self.quantityStepper = [[UIStepper alloc] initWithFrame:CGRectMake(width - 110, 280, 94, 29)];
    self.quantityStepper.minimumValue = 1;
    self.quantityStepper.maximumValue = 100;
    self.quantityStepper.value = self.spawnQuantity;
    self.quantityStepper.tintColor = [UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:1.0];
    [self.quantityStepper addTarget:self action:@selector(quantityChanged:) forControlEvents:UIControlEventValueChanged];
    [itemSection addSubview:self.quantityStepper];
    
    // Spawn button with gradient
    UIButton *spawnBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    spawnBtn.frame = CGRectMake(12, 330, width - 24, 50);
    [spawnBtn setTitle:@"⚡ Spawn Item" forState:UIControlStateNormal];
    [spawnBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    spawnBtn.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    
    CAGradientLayer *spawnGradient = [CAGradientLayer layer];
    spawnGradient.frame = spawnBtn.bounds;
    spawnGradient.colors = @[
        (id)[UIColor colorWithRed:0.3 green:0.5 blue:1.0 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.2 green:0.4 blue:0.9 alpha:1.0].CGColor
    ];
    spawnGradient.cornerRadius = 10;
    [spawnBtn.layer insertSublayer:spawnGradient atIndex:0];
    
    [spawnBtn addTarget:self action:@selector(spawnItem) forControlEvents:UIControlEventTouchUpInside];
    [itemSection addSubview:spawnBtn];
    
    // Status label
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 395, width - 24, 30)];
    statusLabel.text = self.useCustomLocation ? @"📍 Using custom location" : @"📍 Spawning at player";
    statusLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    statusLabel.font = [UIFont systemFontOfSize:11];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.numberOfLines = 2;
    [self.contentView addSubview:statusLabel];
    
    self.contentScrollView.contentSize = CGSizeMake(self.contentView.bounds.size.width, 450);
}

#pragma mark - Settings Tab

- (void)loadSettingsTab {
    CGFloat width = self.contentView.bounds.size.width - 24;
    CGFloat yPos = 15;
    
    // Location Picker Section
    UIView *locationSection = [self createSectionWithTitle:@"Spawn Location" 
                                                     frame:CGRectMake(12, yPos, width, 180)
                                                     color:[UIColor colorWithRed:0.15 green:0.18 blue:0.22 alpha:1.0]];
    [self.contentView addSubview:locationSection];
    
    self.locationPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(12, 40, width - 24, 130)];
    self.locationPicker.delegate = self;
    self.locationPicker.dataSource = self;
    self.locationPicker.tag = 5000;
    self.locationPicker.backgroundColor = [UIColor colorWithRed:0.14 green:0.16 blue:0.19 alpha:1.0];
    self.locationPicker.layer.cornerRadius = 8;
    [self.locationPicker selectRow:self.selectedLocationIndex inComponent:0 animated:NO];
    [locationSection addSubview:self.locationPicker];
    
    yPos += 200;
    
    // Custom Location Section (if enabled)
    if (self.selectedLocationIndex == 0 && self.useCustomLocation) {
        UIView *customSection = [self createSectionWithTitle:@"Custom Coordinates" 
                                                       frame:CGRectMake(12, yPos, width, 240)
                                                       color:[UIColor colorWithRed:0.15 green:0.17 blue:0.20 alpha:1.0]];
        [self.contentView addSubview:customSection];
        
        // X, Y, Z coordinate fields
        NSArray *coords = @[@"X", @"Y", @"Z"];
        NSArray *values = @[@(self.customX), @(self.customY), @(self.customZ)];
        
        for (int i = 0; i < 3; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 45 + (i * 55), 40, 28)];
            label.text = coords[i];
            label.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
            label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
            [customSection addSubview:label];
            
            UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(60, 40 + (i * 55), width - 84, 38)];
            field.text = [NSString stringWithFormat:@"%.2f", [values[i] floatValue]];
            field.backgroundColor = [UIColor colorWithRed:0.18 green:0.20 blue:0.24 alpha:1.0];
            field.textColor = [UIColor whiteColor];
            field.layer.cornerRadius = 6;
            field.textAlignment = NSTextAlignmentCenter;
            field.keyboardType = UIKeyboardTypeDecimalPad;
            field.tag = 3001 + i;
            [field addTarget:self action:@selector(updateCustomLocation) forControlEvents:UIControlEventEditingChanged];
            [customSection addSubview:field];
        }
        
        // Reset button
        UIButton *resetBtn = [self createButtonWithTitle:@"Reset to Default" 
                                                   frame:CGRectMake(12, 190, width - 24, 40)
                                                   color:[UIColor colorWithRed:0.7 green:0.3 blue:0.3 alpha:1.0]];
        [resetBtn addTarget:self action:@selector(resetLocation) forControlEvents:UIControlEventTouchUpInside];
        [customSection addSubview:resetBtn];
        
        yPos += 260;
    }
    
    // Money Cheat Section
    UIView *moneySection = [self createSectionWithTitle:@"💰 Money Cheats" 
                                                  frame:CGRectMake(12, yPos, width, 120)
                                                  color:[UIColor colorWithRed:0.17 green:0.25 blue:0.15 alpha:1.0]];
    [self.contentView addSubview:moneySection];
    
    UIButton *moneyBtn = [self createButtonWithTitle:@"💵 Give 9,999,999 Money" 
                                               frame:CGRectMake(12, 40, width - 24, 50)
                                               color:[UIColor colorWithRed:0.2 green:0.7 blue:0.2 alpha:1.0]];
    [moneyBtn addTarget:self action:@selector(giveMoney) forControlEvents:UIControlEventTouchUpInside];
    [moneySection addSubview:moneyBtn];
    
    yPos += 140;
    
    // Combat Cheats Section
    UIView *combatSection = [self createSectionWithTitle:@"⚔️ Combat Cheats" 
                                                   frame:CGRectMake(12, yPos, width, 120)
                                                   color:[UIColor colorWithRed:0.25 green:0.15 blue:0.15 alpha:1.0]];
    [self.contentView addSubview:combatSection];
    
    UIButton *ammoBtn = [self createButtonWithTitle:@"∞ Infinite Ammo" 
                                              frame:CGRectMake(12, 40, width - 24, 50)
                                              color:[UIColor colorWithRed:0.8 green:0.3 blue:0.3 alpha:1.0]];
    [ammoBtn addTarget:self action:@selector(giveInfiniteAmmo) forControlEvents:UIControlEventTouchUpInside];
    [combatSection addSubview:ammoBtn];
    
    yPos += 140;
    
    // Shop Cheats Section
    UIView *shopSection = [self createSectionWithTitle:@"🛒 Shop Cheats" 
                                                  frame:CGRectMake(12, yPos, width, 120)
                                                  color:[UIColor colorWithRed:0.15 green:0.15 blue:0.22 alpha:1.0]];
    [self.contentView addSubview:shopSection];
    
    UIButton *cooldownBtn = [self createButtonWithTitle:@"🚫 No Buy Cooldown" 
                                                  frame:CGRectMake(12, 40, width - 24, 50)
                                                  color:[UIColor colorWithRed:0.5 green:0.5 blue:0.7 alpha:1.0]];
    [cooldownBtn addTarget:self action:@selector(removeShopCooldown) forControlEvents:UIControlEventTouchUpInside];
    [shopSection addSubview:cooldownBtn];
    
    yPos += 140;
    
    // Community Section
    UIView *communitySection = [self createSectionWithTitle:@"🌐 Community" 
                                                      frame:CGRectMake(12, yPos, width, 120)
                                                      color:[UIColor colorWithRed:0.15 green:0.18 blue:0.25 alpha:1.0]];
    [self.contentView addSubview:communitySection];
    
    UIButton *discordBtn = [self createButtonWithTitle:@"💬 Join Discord" 
                                                 frame:CGRectMake(12, 40, width - 24, 50)
                                                 color:[UIColor colorWithRed:0.35 green:0.4 blue:0.65 alpha:1.0]];
    [discordBtn addTarget:self action:@selector(openDiscord) forControlEvents:UIControlEventTouchUpInside];
    [communitySection addSubview:discordBtn];
    
    yPos += 140;
    
    self.contentScrollView.contentSize = CGSizeMake(self.contentView.bounds.size.width, yPos + 20);
}

#pragma mark - UI Helper Methods

- (UIView *)createSectionWithTitle:(NSString *)title frame:(CGRect)frame color:(UIColor *)color {
    UIView *section = [[UIView alloc] initWithFrame:frame];
    section.backgroundColor = color;
    section.layer.cornerRadius = 12;
    section.layer.borderWidth = 1;
    section.layer.borderColor = [UIColor colorWithRed:0.4 green:0.5 blue:0.7 alpha:0.3].CGColor;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, frame.size.width - 24, 24)];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0];
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [section addSubview:titleLabel];
    
    return section;
}

- (UIButton *)createButtonWithTitle:(NSString *)title frame:(CGRect)frame color:(UIColor *)color {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    btn.backgroundColor = color;
    btn.layer.cornerRadius = 10;
    
    // Add shadow
    btn.layer.shadowColor = color.CGColor;
    btn.layer.shadowRadius = 8;
    btn.layer.shadowOpacity = 0.4;
    btn.layer.shadowOffset = CGSizeMake(0, 2);
    
    return btn;
}

#pragma mark - Actions

- (void)searchItems:(UITextField *)textField {
    NSString *searchText = [textField.text lowercaseString];
    
    if (searchText.length == 0) {
        self.filteredItems = nil;
    } else {
        NSMutableArray *filtered = [NSMutableArray array];
        for (NSString *item in self.availableItems) {
            if ([[item lowercaseString] containsString:searchText]) {
                [filtered addObject:item];
            }
        }
        self.filteredItems = [filtered copy];
    }
    
    [self.itemPicker reloadAllComponents];
    [self.itemPicker selectRow:0 inComponent:0 animated:NO];
}

- (void)quantityChanged:(UIStepper *)stepper {
    self.spawnQuantity = (NSInteger)stepper.value;
    self.quantityLabel.text = [NSString stringWithFormat:@"%ld", (long)self.spawnQuantity];
    [self saveSettings];
}

- (void)updateCustomLocation {
    UITextField *xField = [self.contentView viewWithTag:3001];
    UITextField *yField = [self.contentView viewWithTag:3002];
    UITextField *zField = [self.contentView viewWithTag:3003];
    
    self.customX = xField.text.floatValue;
    self.customY = yField.text.floatValue;
    self.customZ = zField.text.floatValue;
    self.useCustomLocation = YES;
    
    [self saveSettings];
    AudioServicesPlaySystemSound(1519);
}

- (void)resetLocation {
    self.useCustomLocation = NO;
    self.customX = 0;
    self.customY = 3.0;
    self.customZ = 0;
    self.selectedLocationIndex = 0;
    
    [self saveSettings];
    AudioServicesPlaySystemSound(1519);
    [self showAlert:@"✅ Reset" message:@"Location settings restored to default!"];
    [self loadCurrentTab];
}

- (void)spawnItem {
    AudioServicesPlaySystemSound(1519);
    
    NSArray *items = self.filteredItems ?: self.availableItems;
    if (self.selectedItemIndex >= items.count) {
        [self showAlert:@"❌ Error" message:@"Invalid item selection"];
        return;
    }
    
    NSString *itemName = items[self.selectedItemIndex];
    
    // Show what item would be spawned
    NSString *message = [NSString stringWithFormat:
        @"Item: %@\nQuantity: %ld\n\nPosition: (%.2f, %.2f, %.2f)\n\n⚠️ Note: IL2CPP spawning is not yet implemented. Use a mod menu app or console commands to spawn items.",
        itemName, (long)self.spawnQuantity, self.customX, self.customY, self.customZ];
    
    [self showAlert:@"📦 Item Info" message:message];
}

- (void)giveMoney {
    AudioServicesPlaySystemSound(1519);
    
    NSString *message = @"💰 Money Cheat\n\nTo add money:\n1. Open the game console\n2. Use: givemoney 9999999\n\n⚠️ Note: IL2CPP method hooking is not yet supported in this version.";
    
    [self showAlert:@"💸 Money Cheat" message:message];
}

- (void)giveInfiniteAmmo {
    AudioServicesPlaySystemSound(1519);
    
    NSString *message = @"⚡ Infinite Ammo\n\nTo enable infinite ammo:\n1. Open the game console\n2. Use: infiniteammo on\n\n⚠️ Note: IL2CPP method hooking is not yet supported in this version.";
    
    [self showAlert:@"∞ Infinite Ammo" message:message];
}

- (void)removeShopCooldown {
    AudioServicesPlaySystemSound(1519);
    
    NSString *message = @"🛒 Remove Buy Cooldown\n\nTo remove shop cooldown:\n1. Open the game console\n2. Use: shopcooldown 0\n\n⚠️ Note: IL2CPP method hooking is not yet supported in this version.";
    
    [self showAlert:@"🚫 Shop Cooldown" message:message];
}

- (void)openDiscord {
    NSURL *url = [NSURL URLWithString:@"https://discord.gg/fatemod"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (void)closeMenu {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 5000) {
        return self.presetLocations.count;
    }
    return self.filteredItems ? self.filteredItems.count : self.availableItems.count;
}

#pragma mark - UIPickerView Delegate

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView 
             attributedTitleForRow:(NSInteger)row 
                      forComponent:(NSInteger)component {
    NSString *title;
    
    if (pickerView.tag == 5000) {
        title = self.presetLocations[row];
    } else {
        NSArray *items = self.filteredItems ?: self.availableItems;
        title = items[row];
    }
    
    NSDictionary *attrs = @{
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightMedium]
    };
    
    return [[NSAttributedString alloc] initWithString:title attributes:attrs];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == 5000) {
        self.selectedLocationIndex = row;
        self.useCustomLocation = (row == 0);
        [self saveSettings];
        [self loadCurrentTab];
    } else {
        NSArray *items = self.filteredItems ?: self.availableItems;
        NSString *selectedItem = items[row];
        self.selectedItemIndex = [self.availableItems indexOfObject:selectedItem];
        [self saveSettings];
    }
}

#pragma mark - Settings Persistence

- (void)saveSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:self.customX forKey:@"Fate_CustomX"];
    [defaults setFloat:self.customY forKey:@"Fate_CustomY"];
    [defaults setFloat:self.customZ forKey:@"Fate_CustomZ"];
    [defaults setBool:self.useCustomLocation forKey:@"Fate_UseCustom"];
    [defaults setInteger:self.selectedLocationIndex forKey:@"Fate_LocationIndex"];
    [defaults setInteger:self.spawnQuantity forKey:@"Fate_Quantity"];
    [defaults setInteger:self.selectedItemIndex forKey:@"Fate_ItemIndex"];
    [defaults synchronize];
}

- (void)loadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.customX = [defaults floatForKey:@"Fate_CustomX"];
    self.customY = [defaults floatForKey:@"Fate_CustomY"] ?: 3.0;
    self.customZ = [defaults floatForKey:@"Fate_CustomZ"];
    self.useCustomLocation = [defaults boolForKey:@"Fate_UseCustom"];
    self.selectedLocationIndex = [defaults integerForKey:@"Fate_LocationIndex"];
    self.spawnQuantity = [defaults integerForKey:@"Fate_Quantity"] ?: 1;
    self.selectedItemIndex = [defaults integerForKey:@"Fate_ItemIndex"];
}

#pragma mark - Alert Helper

- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end