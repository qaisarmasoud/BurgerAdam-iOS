import uuid

def generate_pbxproj():
    # Helper to generate 24-character hex ID
    def new_id():
        return uuid.uuid4().hex[:24].upper()

    project_id = new_id()
    target_id = new_id()
    main_group_id = new_id()
    sources_phase_id = new_id()
    resources_phase_id = new_id()
    frameworks_phase_id = new_id()
    config_list_project_id = new_id()
    config_list_target_id = new_id()
    debug_project_id = new_id()
    release_project_id = new_id()
    debug_target_id = new_id()
    release_target_id = new_id()

    # Source files
    files = [
        ("BurgerAdamApp.swift", "BurgerAdam/BurgerAdamApp.swift"),
        ("MenuItem.swift", "BurgerAdam/Models/MenuItem.swift"),
        ("Order.swift", "BurgerAdam/Models/Order.swift"),
        ("Expense.swift", "BurgerAdam/Models/Expense.swift"),
        ("DataManager.swift", "BurgerAdam/Models/DataManager.swift"),
        ("ReceiptView.swift", "BurgerAdam/Views/ReceiptView.swift"),
        ("CartView.swift", "BurgerAdam/Views/CartView.swift"),
        ("CashierView.swift", "BurgerAdam/Views/CashierView.swift"),
        ("ExpensesView.swift", "BurgerAdam/Views/ExpensesView.swift"),
        ("ReportsView.swift", "BurgerAdam/Views/ReportsView.swift"),
        ("SettingsAndBackupView.swift", "BurgerAdam/Views/SettingsAndBackupView.swift"),
        ("ItemCustomizerView.swift", "BurgerAdam/Views/ItemCustomizerView.swift"),
        ("ZReportView.swift", "BurgerAdam/Views/ZReportView.swift"),
        ("MainiPadView.swift", "BurgerAdam/Views/MainiPadView.swift")
    ]

    source_entries = []
    for name, path in files:
        f_ref = new_id()
        b_ref = new_id()
        source_entries.append((name, path, f_ref, b_ref))

    # Resources
    assets_f_ref = new_id()
    assets_b_ref = new_id()

    # Product
    product_f_ref = new_id()

    pbx = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 55;
	objects = {{

/* Begin PBXBuildFile section */
"""
    for name, path, f_ref, b_ref in source_entries:
        pbx += f"\t\t{b_ref} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {f_ref} /* {name} */; }};\n"
    pbx += f"\t\t{assets_b_ref} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_f_ref} /* Assets.xcassets */; }};\n"
    pbx += f"""/* End PBXBuildFile section */

/* Begin PBXFileReference section */
\t\t{product_f_ref} /* BurgerAdam.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = BurgerAdam.app; sourceTree = BUILT_PRODUCTS_DIR; }};
"""
    for name, path, f_ref, b_ref in source_entries:
        pbx += f"\t\t{f_ref} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{path}\"; sourceTree = \"<group>\"; }};\n"
    pbx += f"\t\t{assets_f_ref} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = BurgerAdam/Assets.xcassets; sourceTree = \"<group>\"; }};\n"
    pbx += f"""/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{frameworks_phase_id} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{main_group_id} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
"""
    for name, path, f_ref, b_ref in source_entries:
        pbx += f"\t\t\t\t{f_ref} /* {name} */,\n"
    pbx += f"""\t\t\t\t{assets_f_ref} /* Assets.xcassets */,
\t\t\t\t{product_f_ref} /* BurgerAdam.app */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{target_id} /* BurgerAdam */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {config_list_target_id} /* Build configuration list for PBXNativeTarget "BurgerAdam" */;
\t\t\tbuildPhases = (
\t\t\t\t{sources_phase_id} /* Sources */,
\t\t\t\t{frameworks_phase_id} /* Frameworks */,
\t\t\t\t{resources_phase_id} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = BurgerAdam;
\t\t\tproductName = BurgerAdam;
\t\t\tproductReference = {product_f_ref} /* BurgerAdam.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{project_id} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1400;
\t\t\t\tLastUpgradeCheck = 1400;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{target_id} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 14.0;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {config_list_project_id} /* Build configuration list for PBXProject "BurgerAdam" */;
\t\t\tcompatibilityVersion = "Xcode 13.0";
\t\t\tdevelopmentRegion = ar;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\tar,
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {main_group_id};
\t\t\tproductRefGroup = {main_group_id};
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{target_id} /* BurgerAdam */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{resources_phase_id} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{assets_b_ref} /* Assets.xcassets in Resources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{sources_phase_id} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
"""
    for name, path, f_ref, b_ref in source_entries:
        pbx += f"\t\t\t\t{b_ref} /* {name} in Sources */,\n"
    pbx += f"""\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t{debug_project_id} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{release_project_id} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{debug_target_id} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_STYLE = Manual;
\t\t\t\tCODE_SIGNING_ALLOWED = NO;
\t\t\t\tCODE_SIGN_IDENTITY = "";
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = BurgerAdam/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;
\t\t\t\tMARKETING_VERSION = 1.0.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.burgeradam.pos;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{release_target_id} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_STYLE = Manual;
\t\t\t\tCODE_SIGNING_ALLOWED = NO;
\t\t\t\tCODE_SIGN_IDENTITY = "";
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = BurgerAdam/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;
\t\t\t\tMARKETING_VERSION = 1.0.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.burgeradam.pos;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{config_list_project_id} /* Build configuration list for PBXProject "BurgerAdam" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_project_id} /* Debug */,
\t\t\t\t{release_project_id} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{config_list_target_id} /* Build configuration list for PBXNativeTarget "BurgerAdam" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_target_id} /* Debug */,
\t\t\t\t{release_target_id} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */

	}};
	rootObject = {project_id} /* Project object */;
}}
"""
    with open(r"C:\Users\baraa\Desktop\BurgerAdam-iOS\BurgerAdam.xcodeproj\project.pbxproj", "w", encoding="utf-8") as f:
        f.write(pbx)
    print("PBXProj written successfully!")

if __name__ == "__main__":
    generate_pbxproj()
