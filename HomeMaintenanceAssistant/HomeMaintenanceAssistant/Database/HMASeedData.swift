//
//  HMASeedData.swift
//  HomeMaintenanceAssistant
//
//  Bundled offline content: 10 areas, 120 maintenance tasks (12 per area),
//  and 60 historical maintenance records. Generated once on first launch.
//

import Foundation

enum HMASeedData {

    // MARK: - Areas (10)

    static let areas: [HMAArea] = [
        HMAArea(id: 1,  name: "Kitchen",     icon: "fork.knife"),
        HMAArea(id: 2,  name: "Bathroom",    icon: "shower.fill"),
        HMAArea(id: 3,  name: "Bedroom",     icon: "bed.double.fill"),
        HMAArea(id: 4,  name: "Living Room", icon: "sofa.fill"),
        HMAArea(id: 5,  name: "Garage",      icon: "car.fill"),
        HMAArea(id: 6,  name: "Roof",        icon: "house.fill"),
        HMAArea(id: 7,  name: "Garden",      icon: "leaf.fill"),
        HMAArea(id: 8,  name: "HVAC",        icon: "wind"),
        HMAArea(id: 9,  name: "Electrical",  icon: "bolt.fill"),
        HMAArea(id: 10, name: "Plumbing",    icon: "drop.fill")
    ]

    // MARK: - Task template

    /// Compact template expanded into a full HMATask during seeding.
    private struct HMASeedTask {
        let title: String
        let detail: String
        let difficulty: HMADifficulty
        let frequency: HMAFrequency
        let minutes: Int
        let tools: String
        let safety: String
        let steps: [String]
    }

    // MARK: - Per-area task content (12 each → 120)

    private static func HMAtasks(for areaId: Int) -> [HMASeedTask] {
        switch areaId {
        case 1: return HMAkitchenTasks
        case 2: return HMAbathroomTasks
        case 3: return HMAbedroomTasks
        case 4: return HMAlivingRoomTasks
        case 5: return HMAgarageTasks
        case 6: return HMAroofTasks
        case 7: return HMAgardenTasks
        case 8: return HMAhvacTasks
        case 9: return HMAelectricalTasks
        case 10: return HMAplumbingTasks
        default: return []
        }
    }

    /// Materialises the templates into persisted tasks with stable ids.
    static func HMAbuildTasks() -> [HMATask] {
        var built: [HMATask] = []
        var taskId = 1
        for area in areas {
            for t in HMAtasks(for: area.id) {
                built.append(HMATask(id: taskId,
                                     areaId: area.id,
                                     title: t.title,
                                     detail: t.detail,
                                     difficulty: t.difficulty,
                                     frequency: t.frequency,
                                     estimatedMinutes: t.minutes,
                                     tools: t.tools,
                                     safety: t.safety,
                                     procedure: t.steps.enumerated()
                                        .map { "\($0.offset + 1). \($0.element)" }
                                        .joined(separator: "\n")))
                taskId += 1
            }
        }
        return built
    }

    // MARK: - Records (60)

    static func HMAbuildRecords() -> [HMARecord] {
        let total = HMAbuildTasks().count
        guard total > 0 else { return [] }
        var records: [HMARecord] = []
        let now = Date()
        let day: TimeInterval = 86_400
        let resultCycle: [HMARecordResult] = [
            .completed, .completed, .completed, .needsAttention, .completed, .scheduled
        ]
        let notesPool = [
            "Routine check, everything in good condition.",
            "Replaced consumable part, working as expected.",
            "Minor wear noted, will monitor next cycle.",
            "Cleaned and inspected, no issues found.",
            "Recommend professional follow-up soon.",
            "Completed ahead of schedule.",
            ""
        ]

        // 60 deterministic records spread across the last ~10 months.
        for i in 0..<60 {
            let taskId = (i * 7) % total + 1           // spread across tasks
            let daysAgo = Double(8 + i * 5)            // 8 .. ~303 days ago
            let result = resultCycle[i % resultCycle.count]
            let notes = notesPool[i % notesPool.count]
            records.append(HMARecord(id: 0,
                                     taskId: taskId,
                                     date: now.addingTimeInterval(-daysAgo * day),
                                     result: result,
                                     notes: notes))
        }
        return records
    }

    // MARK: - Kitchen

    private static let HMAkitchenTasks: [HMASeedTask] = [
        HMASeedTask(title: "Clean Range Hood Filter", detail: "Degrease and wash the metal mesh filter that traps cooking grease.", difficulty: .easy, frequency: .monthly, minutes: 20, tools: "Degreaser, warm water, soft brush", safety: "Switch off the hood and let it cool before removing the filter.", steps: ["Slide out the metal mesh filter", "Soak in hot water with degreaser for 10 minutes", "Scrub gently and rinse", "Dry fully before reinstalling"]),
        HMASeedTask(title: "Descale Coffee Maker", detail: "Remove mineral buildup to keep brewing temperature and flow correct.", difficulty: .easy, frequency: .quarterly, minutes: 30, tools: "Descaling solution or white vinegar, water", safety: "Unplug after the cycle and let parts cool.", steps: ["Fill reservoir with descaler and water", "Run a full brew cycle into a carafe", "Run two cycles of clean water", "Wipe the exterior"]),
        HMASeedTask(title: "Clean Refrigerator Coils", detail: "Dust on condenser coils forces the compressor to work harder.", difficulty: .moderate, frequency: .biannual, minutes: 30, tools: "Coil brush, vacuum with crevice tool", safety: "Unplug the refrigerator before reaching behind it.", steps: ["Pull the fridge away from the wall", "Locate coils at the back or beneath", "Brush loose dust free", "Vacuum the area and reconnect power"]),
        HMASeedTask(title: "Check Sink Drain Flow", detail: "Confirm the kitchen sink drains quickly and check for leaks below.", difficulty: .easy, frequency: .monthly, minutes: 15, tools: "Flashlight, bucket", safety: "Avoid chemical drain cleaners with garbage disposals.", steps: ["Fill the basin and release the water", "Watch drain speed for slowdowns", "Inspect the trap for drips", "Tighten fittings if needed"]),
        HMASeedTask(title: "Clean Oven Interior", detail: "Remove baked-on residue to prevent smoke and odours.", difficulty: .moderate, frequency: .quarterly, minutes: 60, tools: "Oven cleaner or baking soda paste, cloths", safety: "Ventilate the room and wear gloves with cleaners.", steps: ["Remove racks and soak separately", "Apply cleaner to interior surfaces", "Let it sit per product instructions", "Wipe clean and reinstall racks"]),
        HMASeedTask(title: "Inspect Dishwasher Seal", detail: "A worn door gasket lets water escape onto the floor.", difficulty: .easy, frequency: .biannual, minutes: 15, tools: "Cloth, mild soap", safety: "Run cycles only after the seal is fully reseated.", steps: ["Open the door and inspect the gasket", "Wipe away food debris and mould", "Check for cracks or stiffness", "Replace the gasket if damaged"]),
        HMASeedTask(title: "Sharpen Kitchen Knives", detail: "Keep edges safe and effective; dull blades cause slips.", difficulty: .easy, frequency: .quarterly, minutes: 20, tools: "Whetstone or pull-through sharpener", safety: "Cut away from your body and keep fingers clear of the edge.", steps: ["Wet the whetstone if required", "Hold a consistent angle", "Draw the blade across both sides evenly", "Rinse and dry the knife"]),
        HMASeedTask(title: "Clean Garbage Disposal", detail: "Freshen and clear the disposal to stop odours and clogs.", difficulty: .easy, frequency: .monthly, minutes: 15, tools: "Ice cubes, citrus peel, baking soda", safety: "Never put your hand inside the disposal chamber.", steps: ["Run ice cubes through the disposal", "Add citrus peel and run with cold water", "Pour baking soda and rinse", "Confirm smooth operation"]),
        HMASeedTask(title: "Check Faucet Aerator", detail: "Clean the aerator screen to restore steady water pressure.", difficulty: .easy, frequency: .biannual, minutes: 15, tools: "Pliers, cloth, vinegar", safety: "Hand-tighten to avoid cracking the fixture.", steps: ["Unscrew the aerator by hand or with cloth-wrapped pliers", "Soak in vinegar to dissolve scale", "Rinse the screen", "Reattach and test flow"]),
        HMASeedTask(title: "Test Under-Sink Shutoff", detail: "Verify the supply valves turn freely in case of an emergency.", difficulty: .easy, frequency: .annual, minutes: 10, tools: "Flashlight", safety: "Do not force a seized valve; call a plumber.", steps: ["Locate hot and cold shutoff valves", "Turn each valve closed then open", "Check for drips at the stem", "Note any stiff valves"]),
        HMASeedTask(title: "Deep Clean Microwave", detail: "Loosen splatter with steam and wipe the cavity and turntable.", difficulty: .easy, frequency: .monthly, minutes: 15, tools: "Bowl, water, lemon, cloth", safety: "Use a microwave-safe bowl and handle hot water carefully.", steps: ["Microwave a bowl of water and lemon for 3 minutes", "Let steam sit for 2 minutes", "Wipe interior surfaces", "Clean the turntable separately"]),
        HMASeedTask(title: "Inspect Cabinet Hinges", detail: "Tighten and lubricate hinges so doors close flush.", difficulty: .easy, frequency: .biannual, minutes: 25, tools: "Screwdriver, lubricant", safety: "Support doors while removing screws.", steps: ["Open each cabinet door", "Tighten loose hinge screws", "Apply a drop of lubricant", "Confirm doors align and close"])
    ]

    // MARK: - Bathroom

    private static let HMAbathroomTasks: [HMASeedTask] = [
        HMASeedTask(title: "Reseal Bathtub Caulk", detail: "Replace cracked caulk to keep water out of the wall cavity.", difficulty: .moderate, frequency: .annual, minutes: 60, tools: "Caulk gun, silicone caulk, utility knife", safety: "Ventilate and avoid skin contact with uncured silicone.", steps: ["Cut out old caulk", "Clean and dry the joint", "Apply a continuous silicone bead", "Smooth and let cure 24 hours"]),
        HMASeedTask(title: "Clean Showerhead", detail: "Dissolve mineral scale to restore even spray.", difficulty: .easy, frequency: .quarterly, minutes: 20, tools: "Vinegar, bag, rubber band", safety: "Avoid mixing cleaning chemicals.", steps: ["Fill a bag with vinegar", "Secure it around the showerhead", "Soak for one hour", "Run water to flush loosened scale"]),
        HMASeedTask(title: "Check Toilet for Leaks", detail: "A dye test reveals a silent flapper leak that wastes water.", difficulty: .easy, frequency: .quarterly, minutes: 15, tools: "Food colouring", safety: "Do not flush dye into a septic system repeatedly.", steps: ["Add dye to the tank", "Wait 15 minutes without flushing", "Check if colour appears in the bowl", "Replace the flapper if it leaks"]),
        HMASeedTask(title: "Clear Sink Pop-Up Drain", detail: "Remove hair and gunk from the bathroom sink stopper.", difficulty: .easy, frequency: .monthly, minutes: 15, tools: "Gloves, cloth", safety: "Wear gloves when handling drain debris.", steps: ["Lift or unscrew the pop-up stopper", "Pull out hair and buildup", "Rinse the stopper", "Reinstall and test drainage"]),
        HMASeedTask(title: "Inspect Grout Lines", detail: "Repair failing grout before moisture reaches the substrate.", difficulty: .moderate, frequency: .biannual, minutes: 45, tools: "Grout, float, grout saw", safety: "Wear a dust mask when grinding out grout.", steps: ["Inspect tile joints for cracks", "Rake out crumbling grout", "Apply fresh grout", "Wipe haze after it sets"]),
        HMASeedTask(title: "Run Exhaust Fan Check", detail: "Confirm the vent fan clears humidity to prevent mould.", difficulty: .easy, frequency: .quarterly, minutes: 15, tools: "Vacuum, screwdriver", safety: "Cut power before removing the fan cover.", steps: ["Remove the fan cover", "Vacuum dust from the blades", "Confirm strong airflow with a tissue test", "Reinstall the cover"]),
        HMASeedTask(title: "Test Hot Water Recovery", detail: "Time how quickly hot water returns to spot heater issues.", difficulty: .easy, frequency: .annual, minutes: 15, tools: "Thermometer (optional)", safety: "Set water heater no higher than 49°C to avoid scalding.", steps: ["Run hot water until it cools", "Time the return of hot water", "Note unusually long delays", "Log results for comparison"]),
        HMASeedTask(title: "Clean Drain Overflow", detail: "Flush the hidden overflow channel that can harbour bacteria.", difficulty: .easy, frequency: .biannual, minutes: 15, tools: "Baking soda, vinegar, funnel", safety: "Avoid splashing cleaning mixtures.", steps: ["Pour baking soda into the overflow", "Follow with vinegar", "Let it fizz for 10 minutes", "Flush with warm water"]),
        HMASeedTask(title: "Check Caulk Around Sink", detail: "Seal gaps between the vanity and wall against splashes.", difficulty: .easy, frequency: .annual, minutes: 30, tools: "Caulk, utility knife", safety: "Let caulk cure before use.", steps: ["Inspect the sink-to-wall joint", "Remove damaged caulk", "Apply a fresh bead", "Smooth and let cure"]),
        HMASeedTask(title: "Lubricate Faucet Handles", detail: "Stiff handles signal dry cartridges that wear out faster.", difficulty: .moderate, frequency: .annual, minutes: 30, tools: "Plumber's grease, hex key", safety: "Shut off supply valves before disassembly.", steps: ["Close the supply valves", "Remove the handle", "Apply plumber's grease to the cartridge", "Reassemble and test"]),
        HMASeedTask(title: "Inspect Toilet Bolts", detail: "Loose closet bolts let the toilet rock and break the wax seal.", difficulty: .easy, frequency: .biannual, minutes: 15, tools: "Wrench, cloth", safety: "Tighten gently to avoid cracking porcelain.", steps: ["Remove bolt caps", "Snug the bolts evenly", "Check for rocking", "Replace caps"]),
        HMASeedTask(title: "Scrub Tile and Reseal", detail: "Clean tile and reapply sealer to repel water and stains.", difficulty: .moderate, frequency: .annual, minutes: 60, tools: "Tile cleaner, sealer, applicator", safety: "Ventilate when applying sealer.", steps: ["Deep clean tile and grout", "Let surfaces dry fully", "Apply grout sealer", "Buff away excess"])
    ]

    // MARK: - Bedroom

    private static let HMAbedroomTasks: [HMASeedTask] = [
        HMASeedTask(title: "Rotate Mattress", detail: "Even out wear so the mattress lasts and stays supportive.", difficulty: .easy, frequency: .quarterly, minutes: 15, tools: "None", safety: "Lift with your legs and ask for help with heavy mattresses.", steps: ["Strip the bedding", "Rotate the mattress 180 degrees", "Flip if double-sided", "Remake the bed"]),
        HMASeedTask(title: "Clean Ceiling Fan Blades", detail: "Dust-laden blades spread allergens and wobble.", difficulty: .easy, frequency: .quarterly, minutes: 20, tools: "Step ladder, microfibre cloth", safety: "Switch the fan off and steady the ladder.", steps: ["Turn off the fan", "Wipe each blade with a damp cloth", "Check blade screws", "Confirm balanced spin"]),
        HMASeedTask(title: "Vacuum Under Bed", detail: "Reduce dust mites and improve air quality.", difficulty: .easy, frequency: .monthly, minutes: 15, tools: "Vacuum with attachment", safety: "Mind your back when moving storage bins.", steps: ["Slide out under-bed storage", "Vacuum the floor area", "Wipe baseboards", "Return items"]),
        HMASeedTask(title: "Inspect Window Seals", detail: "Drafty seals raise heating costs and let in moisture.", difficulty: .easy, frequency: .biannual, minutes: 20, tools: "Weatherstrip, candle for draft test", safety: "Keep open flames away from curtains.", steps: ["Check for drafts around the frame", "Inspect weatherstripping", "Replace worn strips", "Confirm a tight close"]),
        HMASeedTask(title: "Lubricate Door Hinges", detail: "Silence squeaks and keep doors swinging freely.", difficulty: .easy, frequency: .biannual, minutes: 10, tools: "Lubricant, cloth", safety: "Wipe drips to avoid slips.", steps: ["Open the door", "Apply lubricant to each hinge", "Swing the door several times", "Wipe excess"]),
        HMASeedTask(title: "Test Smoke Detector", detail: "Confirm the bedroom alarm sounds and the battery is fresh.", difficulty: .easy, frequency: .monthly, minutes: 10, tools: "Replacement battery", safety: "Do not disable an alarm after testing.", steps: ["Press and hold the test button", "Confirm a loud alarm", "Replace the battery if weak", "Reset the unit"]),
        HMASeedTask(title: "Wash Curtains", detail: "Curtains trap dust and odours over time.", difficulty: .easy, frequency: .biannual, minutes: 45, tools: "Washing machine, gentle detergent", safety: "Check fabric care labels before washing.", steps: ["Remove curtains from rods", "Wash on a gentle cycle", "Hang to dry or steam", "Rehang and adjust"]),
        HMASeedTask(title: "Check Closet Shelving", detail: "Overloaded shelves and brackets can pull free of the wall.", difficulty: .easy, frequency: .annual, minutes: 20, tools: "Screwdriver, level", safety: "Reduce load before tightening anchors.", steps: ["Empty sagging shelves", "Tighten or reset brackets", "Verify level", "Reload evenly"]),
        HMASeedTask(title: "Dust Blinds", detail: "Keep window blinds clean to improve light and air quality.", difficulty: .easy, frequency: .monthly, minutes: 15, tools: "Microfibre duster", safety: "Handle cords away from children.", steps: ["Close the blinds one way", "Dust each slat", "Reverse and repeat", "Spot clean stains"]),
        HMASeedTask(title: "Inspect Outlet Covers", detail: "Cracked covers expose wiring and dust the receptacle.", difficulty: .easy, frequency: .annual, minutes: 15, tools: "Screwdriver, replacement covers", safety: "Do not touch exposed wiring; call an electrician.", steps: ["Inspect each cover for cracks", "Replace damaged covers", "Confirm a snug fit", "Check for warmth or discoloration"]),
        HMASeedTask(title: "Flip and Vacuum Rug", detail: "Reduce wear patterns and lift trapped grit.", difficulty: .easy, frequency: .quarterly, minutes: 20, tools: "Vacuum", safety: "Lift heavy rugs with care.", steps: ["Vacuum the rug surface", "Flip and vacuum the underside", "Sweep the floor beneath", "Rotate the rug position"]),
        HMASeedTask(title: "Check Baseboard Heaters", detail: "Dust buildup on heating fins is a fire risk and cuts output.", difficulty: .easy, frequency: .annual, minutes: 20, tools: "Vacuum, brush", safety: "Turn off the circuit before cleaning fins.", steps: ["Cut power to the heater", "Vacuum the fins", "Brush away stubborn dust", "Restore power and test"])
    ]

    // MARK: - Living Room

    private static let HMAlivingRoomTasks: [HMASeedTask] = [
        HMASeedTask(title: "Vacuum Upholstery", detail: "Lift crumbs and dust from sofas and chairs.", difficulty: .easy, frequency: .monthly, minutes: 20, tools: "Vacuum with upholstery tool", safety: "Check fabric guidance before deep cleaning.", steps: ["Remove cushions", "Vacuum seams and crevices", "Clean cushion surfaces", "Reassemble"]),
        HMASeedTask(title: "Dust Electronics", detail: "Dust traps heat in media equipment and shortens its life.", difficulty: .easy, frequency: .monthly, minutes: 15, tools: "Microfibre cloth, compressed air", safety: "Power down before using compressed air on vents.", steps: ["Power off devices", "Wipe surfaces with a dry cloth", "Blow dust from vents", "Tidy cabling"]),
        HMASeedTask(title: "Inspect TV Mount", detail: "Confirm the wall mount and bolts remain secure.", difficulty: .moderate, frequency: .biannual, minutes: 20, tools: "Hex key, level", safety: "Have a helper support the TV while checking.", steps: ["Check mount bolts at the studs", "Tighten the bracket arms", "Confirm level", "Verify cable strain relief"]),
        HMASeedTask(title: "Clean Window Glass", detail: "Streak-free windows improve natural light.", difficulty: .easy, frequency: .quarterly, minutes: 25, tools: "Glass cleaner, squeegee, cloth", safety: "Use a stable step stool for high panes.", steps: ["Dust the frame", "Spray and wipe the glass", "Squeegee top to bottom", "Buff edges dry"]),
        HMASeedTask(title: "Test Remote Batteries", detail: "Avoid corrosion from old batteries in remotes.", difficulty: .easy, frequency: .biannual, minutes: 10, tools: "Replacement batteries", safety: "Recycle old batteries properly.", steps: ["Open battery compartments", "Inspect for leakage", "Replace weak batteries", "Confirm operation"]),
        HMASeedTask(title: "Fluff and Rotate Cushions", detail: "Even out seating wear and maintain shape.", difficulty: .easy, frequency: .monthly, minutes: 10, tools: "None", safety: "None.", steps: ["Remove cushions", "Fluff filling", "Rotate and flip", "Replace in alternate positions"]),
        HMASeedTask(title: "Inspect Floor Lamps", detail: "Check cords and bulbs for safe operation.", difficulty: .easy, frequency: .biannual, minutes: 15, tools: "Replacement bulb", safety: "Unplug before handling the socket.", steps: ["Unplug the lamp", "Inspect the cord for fraying", "Replace failed bulbs", "Confirm stable footing"]),
        HMASeedTask(title: "Clean Air Vents", detail: "Wipe supply and return registers for better airflow.", difficulty: .easy, frequency: .quarterly, minutes: 20, tools: "Vacuum, cloth, screwdriver", safety: "Mind sharp register edges.", steps: ["Remove the register cover", "Vacuum the duct opening", "Wash the cover", "Reinstall"]),
        HMASeedTask(title: "Check Fireplace Damper", detail: "A stuck damper wastes heat and risks smoke backup.", difficulty: .moderate, frequency: .annual, minutes: 20, tools: "Flashlight, gloves", safety: "Only inspect a cold, unused fireplace.", steps: ["Confirm the fireplace is cold", "Open and close the damper", "Check the seal", "Note creosote buildup for a sweep"]),
        HMASeedTask(title: "Polish Wood Furniture", detail: "Condition wood to prevent drying and cracking.", difficulty: .easy, frequency: .quarterly, minutes: 25, tools: "Wood polish, soft cloth", safety: "Test polish on a hidden spot first.", steps: ["Dust the surface", "Apply polish sparingly", "Buff along the grain", "Remove residue"]),
        HMASeedTask(title: "Secure Area Rugs", detail: "Non-slip backing prevents trip hazards.", difficulty: .easy, frequency: .biannual, minutes: 15, tools: "Rug pad or grip tape", safety: "Address curled edges promptly.", steps: ["Lift the rug", "Add or refresh a non-slip pad", "Flatten edges", "Reposition"]),
        HMASeedTask(title: "Inspect Door Weatherstrip", detail: "Seal the main entry against drafts and pests.", difficulty: .easy, frequency: .biannual, minutes: 20, tools: "Weatherstrip, scissors", safety: "Keep adhesive away from skin.", steps: ["Inspect the door perimeter", "Remove worn strips", "Apply new weatherstrip", "Test the seal with the door closed"])
    ]

    // MARK: - Garage

    private static let HMAgarageTasks: [HMASeedTask] = [
        HMASeedTask(title: "Lubricate Garage Door", detail: "Quiet rollers and hinges and prolong opener life.", difficulty: .easy, frequency: .biannual, minutes: 30, tools: "Garage door lubricant, cloth", safety: "Disconnect the opener before working on tracks.", steps: ["Release the opener", "Apply lubricant to rollers and hinges", "Wipe the tracks clean", "Cycle the door to spread lubricant"]),
        HMASeedTask(title: "Test Auto-Reverse Safety", detail: "Confirm the opener reverses on obstruction to protect people.", difficulty: .easy, frequency: .quarterly, minutes: 15, tools: "Test block (2x4)", safety: "Keep clear of the door path during the test.", steps: ["Place a board under the door", "Close the door", "Confirm it reverses on contact", "Adjust force settings if it fails"]),
        HMASeedTask(title: "Inspect Door Springs", detail: "Worn torsion springs are dangerous and need a pro.", difficulty: .advanced, frequency: .biannual, minutes: 20, tools: "Flashlight", safety: "Never attempt to adjust torsion springs yourself.", steps: ["Visually inspect springs for gaps", "Check cables for fraying", "Note any rust", "Call a technician for repairs"]),
        HMASeedTask(title: "Organise & Check Shelving", detail: "Secure heavy items and confirm anchors hold.", difficulty: .easy, frequency: .annual, minutes: 30, tools: "Screwdriver, level", safety: "Store heavy items low.", steps: ["Clear cluttered shelves", "Tighten wall anchors", "Confirm level", "Reload with heavy items low"]),
        HMASeedTask(title: "Sweep and Degrease Floor", detail: "Remove oil stains that are slip and fire hazards.", difficulty: .easy, frequency: .quarterly, minutes: 30, tools: "Broom, degreaser, absorbent", safety: "Ventilate and avoid ignition sources near solvents.", steps: ["Sweep debris", "Apply absorbent to oil spots", "Scrub with degreaser", "Rinse and dry"]),
        HMASeedTask(title: "Inspect Opener Chain", detail: "Proper chain tension keeps the door moving smoothly.", difficulty: .moderate, frequency: .biannual, minutes: 20, tools: "Wrench, lubricant", safety: "Unplug the opener before adjusting.", steps: ["Unplug the opener", "Check chain sag", "Adjust tension per manual", "Lubricate the rail"]),
        HMASeedTask(title: "Check Weather Seal", detail: "The bottom seal blocks water, drafts and pests.", difficulty: .easy, frequency: .biannual, minutes: 20, tools: "Replacement seal, utility knife", safety: "Cut away from your body.", steps: ["Inspect the bottom seal", "Remove cracked sections", "Slide in a new seal", "Confirm full floor contact"]),
        HMASeedTask(title: "Test GFCI Outlets", detail: "Garage outlets must trip to protect against shock.", difficulty: .easy, frequency: .quarterly, minutes: 10, tools: "None", safety: "Stop using an outlet that fails to reset.", steps: ["Press the TEST button", "Confirm power cuts", "Press RESET", "Verify power returns"]),
        HMASeedTask(title: "Inspect Storage of Chemicals", detail: "Keep paints and fuels stored safely and labelled.", difficulty: .easy, frequency: .biannual, minutes: 20, tools: "Gloves, labels", safety: "Store flammables away from heat and ignition.", steps: ["Check container seals", "Discard expired chemicals safely", "Confirm clear labels", "Store away from heat"]),
        HMASeedTask(title: "Clean Opener Photo-Eye", detail: "Dirty sensors prevent the door from closing.", difficulty: .easy, frequency: .quarterly, minutes: 10, tools: "Soft cloth", safety: "Do not bump sensor alignment.", steps: ["Locate the photo-eye sensors", "Wipe each lens", "Confirm aligned indicator lights", "Test the door close"]),
        HMASeedTask(title: "Check Tool Battery Storage", detail: "Maintain cordless tool batteries for longevity.", difficulty: .easy, frequency: .quarterly, minutes: 15, tools: "Charger", safety: "Store lithium batteries away from heat.", steps: ["Inspect batteries for swelling", "Top up charge to storage level", "Clean contacts", "Store in a dry place"]),
        HMASeedTask(title: "Inspect Manual Release Cord", detail: "Ensure the emergency release works in a power outage.", difficulty: .easy, frequency: .biannual, minutes: 10, tools: "None", safety: "Only test with the door closed.", steps: ["Locate the red release cord", "Pull to disengage", "Move the door by hand", "Re-engage the trolley"])
    ]

    // MARK: - Roof

    private static let HMAroofTasks: [HMASeedTask] = [
        HMASeedTask(title: "Inspect Roof Shingles", detail: "Spot missing or curling shingles before leaks start.", difficulty: .moderate, frequency: .biannual, minutes: 30, tools: "Binoculars, ladder", safety: "Inspect from the ground or a stable ladder; never walk a wet roof.", steps: ["Scan the roof with binoculars", "Note missing or curled shingles", "Check for granule loss in gutters", "Schedule repairs as needed"]),
        HMASeedTask(title: "Clean Gutters", detail: "Clogged gutters cause overflow and foundation damage.", difficulty: .moderate, frequency: .biannual, minutes: 60, tools: "Ladder, gloves, scoop, bucket", safety: "Use a stabilised ladder and a spotter.", steps: ["Scoop out leaves and debris", "Flush gutters with a hose", "Confirm downspouts drain", "Check for sagging sections"]),
        HMASeedTask(title: "Check Flashing Seals", detail: "Flashing around chimneys and vents is a common leak point.", difficulty: .moderate, frequency: .annual, minutes: 30, tools: "Roof sealant, binoculars", safety: "Avoid steep or wet roofs; hire a pro if unsure.", steps: ["Inspect flashing joints", "Look for lifted or rusted metal", "Reseal small gaps", "Flag major issues for a roofer"]),
        HMASeedTask(title: "Inspect Roof Vents", detail: "Blocked vents trap attic heat and moisture.", difficulty: .moderate, frequency: .annual, minutes: 25, tools: "Binoculars, flashlight", safety: "Check soffit vents from inside the attic when possible.", steps: ["Inspect ridge and soffit vents", "Clear nests or debris", "Confirm unobstructed airflow", "Note damaged screens"]),
        HMASeedTask(title: "Check Skylight Seals", detail: "Aging skylight seals leak during heavy rain.", difficulty: .moderate, frequency: .annual, minutes: 25, tools: "Sealant, cloth", safety: "Work only in dry conditions.", steps: ["Inspect the skylight perimeter", "Clean the frame", "Reseal gaps", "Check interior for stains"]),
        HMASeedTask(title: "Trim Overhanging Branches", detail: "Branches scrape shingles and drop debris.", difficulty: .moderate, frequency: .annual, minutes: 45, tools: "Pole saw, gloves", safety: "Keep clear of power lines; hire a pro near them.", steps: ["Identify branches touching the roof", "Cut back to a safe clearance", "Remove debris", "Inspect the roof beneath"]),
        HMASeedTask(title: "Inspect Attic for Leaks", detail: "Water stains in the attic reveal hidden roof leaks.", difficulty: .easy, frequency: .biannual, minutes: 30, tools: "Flashlight", safety: "Step only on joists, never the ceiling drywall.", steps: ["Enter the attic safely", "Scan the underside of the deck", "Look for stains or daylight", "Mark areas for repair"]),
        HMASeedTask(title: "Clear Downspout Drains", detail: "Direct roof runoff away from the foundation.", difficulty: .easy, frequency: .biannual, minutes: 20, tools: "Hose, gloves", safety: "Watch footing near downspout outlets.", steps: ["Flush each downspout", "Clear the outlet of debris", "Confirm water flows away from the house", "Add extensions if needed"]),
        HMASeedTask(title: "Check Chimney Cap", detail: "A damaged cap lets in rain and animals.", difficulty: .moderate, frequency: .annual, minutes: 20, tools: "Binoculars", safety: "Inspect from the ground; hire a sweep for close work.", steps: ["Inspect the cap and screen", "Look for rust or gaps", "Note loose mortar", "Schedule chimney service"]),
        HMASeedTask(title: "Inspect Gutter Guards", detail: "Clean and reseat guards so they keep working.", difficulty: .easy, frequency: .biannual, minutes: 30, tools: "Ladder, brush", safety: "Use a stabilised ladder with a spotter.", steps: ["Brush debris off the guards", "Reseat shifted sections", "Confirm water flow", "Check fasteners"]),
        HMASeedTask(title: "Look for Moss Growth", detail: "Moss holds moisture and degrades shingles.", difficulty: .moderate, frequency: .annual, minutes: 30, tools: "Moss treatment, sprayer", safety: "Avoid pressure washing shingles.", steps: ["Identify mossy areas", "Apply moss treatment", "Let it work per instructions", "Rinse gently"]),
        HMASeedTask(title: "Inspect Fascia and Soffit", detail: "Rotted fascia and soffit invite pests and water.", difficulty: .moderate, frequency: .annual, minutes: 30, tools: "Binoculars, screwdriver", safety: "Probe wood only from a stable ladder.", steps: ["Inspect fascia boards for rot", "Check soffit panels", "Probe soft spots", "Flag repairs"])
    ]

    // MARK: - Garden

    private static let HMAgardenTasks: [HMASeedTask] = [
        HMASeedTask(title: "Inspect Irrigation System", detail: "Check sprinklers and drip lines for leaks and coverage.", difficulty: .moderate, frequency: .seasonal, minutes: 40, tools: "None", safety: "Watch footing on wet ground.", steps: ["Run each zone", "Check for clogged or broken heads", "Adjust spray patterns", "Inspect for line leaks"]),
        HMASeedTask(title: "Sharpen Mower Blade", detail: "A sharp blade cuts cleanly and protects the lawn.", difficulty: .moderate, frequency: .seasonal, minutes: 40, tools: "Wrench, file or grinder, gloves", safety: "Disconnect the spark plug before working on the blade.", steps: ["Disconnect the spark plug", "Remove the blade", "Sharpen and balance", "Reinstall securely"]),
        HMASeedTask(title: "Clean Garden Tools", detail: "Clean, oiled tools resist rust and spread less disease.", difficulty: .easy, frequency: .seasonal, minutes: 30, tools: "Wire brush, oil, cloth", safety: "Mind sharp edges.", steps: ["Scrape off soil", "Wire-brush rust", "Wipe with oil", "Store dry"]),
        HMASeedTask(title: "Inspect Fence Posts", detail: "Loose or rotted posts compromise the whole fence.", difficulty: .moderate, frequency: .annual, minutes: 45, tools: "Level, screwdriver", safety: "Probe carefully for hidden rot.", steps: ["Push-test each post", "Probe the base for rot", "Tighten fasteners", "Flag posts to replace"]),
        HMASeedTask(title: "Service Outdoor Faucet", detail: "Prevent freeze damage and fix drips at hose bibs.", difficulty: .moderate, frequency: .seasonal, minutes: 25, tools: "Wrench, washer kit", safety: "Shut off the interior supply before disassembly.", steps: ["Shut off the supply", "Replace worn washers", "Reassemble the bib", "Test for drips"]),
        HMASeedTask(title: "Check Deck Boards", detail: "Find soft, cracked or loose boards before they fail.", difficulty: .moderate, frequency: .annual, minutes: 40, tools: "Screwdriver, screws", safety: "Probe for rot and watch for protruding nails.", steps: ["Walk the deck for soft spots", "Probe suspect boards", "Secure loose boards", "Note boards to replace"]),
        HMASeedTask(title: "Reseal Wood Deck", detail: "Sealer protects decking from sun and moisture.", difficulty: .moderate, frequency: .annual, minutes: 90, tools: "Deck sealer, brush or roller", safety: "Work in dry weather and ventilate.", steps: ["Clean the deck thoroughly", "Let it dry fully", "Apply sealer evenly", "Allow proper cure time"]),
        HMASeedTask(title: "Inspect Retaining Wall", detail: "Bulging or cracked walls signal drainage problems.", difficulty: .moderate, frequency: .annual, minutes: 30, tools: "Level, flashlight", safety: "Keep clear of unstable sections.", steps: ["Inspect for bulging", "Check weep holes drain", "Note cracks", "Plan repairs for movement"]),
        HMASeedTask(title: "Clean Patio Furniture", detail: "Extend the life of outdoor furniture and cushions.", difficulty: .easy, frequency: .seasonal, minutes: 30, tools: "Mild soap, brush, hose", safety: "Let metal frames dry to prevent rust.", steps: ["Brush off debris", "Wash frames and cushions", "Rinse and dry", "Store cushions when not in use"]),
        HMASeedTask(title: "Check Drainage Grading", detail: "Soil should slope away from the foundation.", difficulty: .moderate, frequency: .annual, minutes: 30, tools: "Level, shovel", safety: "Call before you dig near utilities.", steps: ["Inspect grade near the foundation", "Identify pooling areas", "Add soil to restore slope", "Confirm runoff direction"]),
        HMASeedTask(title: "Service Garden Hose", detail: "Fix leaks and store hoses to prevent cracking.", difficulty: .easy, frequency: .seasonal, minutes: 20, tools: "Washer kit, cap", safety: "Drain before freezing weather.", steps: ["Inspect for cracks", "Replace washers", "Flush the hose", "Coil and store"]),
        HMASeedTask(title: "Inspect Outdoor Lighting", detail: "Keep pathway and security lights working safely.", difficulty: .easy, frequency: .seasonal, minutes: 25, tools: "Replacement bulbs", safety: "Cut power to fixtures before servicing.", steps: ["Test each fixture", "Replace failed bulbs", "Clean lenses", "Check for exposed wiring"])
    ]

    // MARK: - HVAC

    private static let HMAhvacTasks: [HMASeedTask] = [
        HMASeedTask(title: "Replace HVAC Filter", detail: "A fresh filter improves airflow, efficiency and air quality.", difficulty: .easy, frequency: .quarterly, minutes: 15, tools: "Replacement filter", safety: "Power off the HVAC system before opening the filter bay.", steps: ["Power off the system", "Remove the old filter", "Insert a new filter with the airflow arrow correct", "Restore power and confirm airflow"]),
        HMASeedTask(title: "Clean Condenser Unit", detail: "Clear debris from the outdoor unit for efficient cooling.", difficulty: .moderate, frequency: .annual, minutes: 45, tools: "Garden hose, fin comb, gloves", safety: "Cut power at the disconnect before cleaning.", steps: ["Shut off power to the unit", "Clear leaves and debris", "Rinse the fins from inside out", "Straighten bent fins"]),
        HMASeedTask(title: "Check Thermostat Accuracy", detail: "Verify the thermostat reads and switches correctly.", difficulty: .easy, frequency: .biannual, minutes: 20, tools: "Thermometer, batteries", safety: "Turn off the system before rewiring.", steps: ["Compare thermostat to a thermometer", "Replace batteries if present", "Test heating and cooling calls", "Recalibrate if available"]),
        HMASeedTask(title: "Clear Condensate Drain", detail: "A clogged drain line causes water damage and shutdowns.", difficulty: .moderate, frequency: .biannual, minutes: 25, tools: "Wet/dry vac, vinegar", safety: "Avoid contact with standing condensate water.", steps: ["Locate the drain line", "Vacuum the outlet to clear the clog", "Flush with vinegar", "Confirm free flow"]),
        HMASeedTask(title: "Inspect Refrigerant Lines", detail: "Damaged insulation reduces efficiency.", difficulty: .easy, frequency: .annual, minutes: 20, tools: "Pipe insulation, tape", safety: "Do not touch refrigerant fittings; call a pro for leaks.", steps: ["Inspect the insulation on the lines", "Replace cracked insulation", "Check for oily residue (leak sign)", "Flag leaks for a technician"]),
        HMASeedTask(title: "Vacuum Supply Registers", detail: "Clean vents distribute conditioned air better.", difficulty: .easy, frequency: .quarterly, minutes: 25, tools: "Vacuum, screwdriver", safety: "Mind sharp register edges.", steps: ["Remove register covers", "Vacuum inside the ducts", "Wash the covers", "Reinstall"]),
        HMASeedTask(title: "Test System Startup", detail: "Confirm clean startup before peak season.", difficulty: .easy, frequency: .seasonal, minutes: 20, tools: "None", safety: "Stop and call a pro on burning smells.", steps: ["Set the thermostat to call for heat or cool", "Listen for smooth startup", "Confirm airflow at vents", "Note unusual noises"]),
        HMASeedTask(title: "Inspect Ductwork Joints", detail: "Leaky ducts waste energy and dust the house.", difficulty: .moderate, frequency: .annual, minutes: 40, tools: "Mastic or foil tape, flashlight", safety: "Wear a mask in dusty attics or crawlspaces.", steps: ["Inspect accessible duct joints", "Feel for air leaks while running", "Seal with mastic or foil tape", "Confirm improved airflow"]),
        HMASeedTask(title: "Clean Blower Compartment", detail: "Dust on the blower reduces airflow and strains the motor.", difficulty: .advanced, frequency: .annual, minutes: 45, tools: "Vacuum, brush, screwdriver", safety: "Cut power at the breaker before opening the unit.", steps: ["Shut off power at the breaker", "Open the blower access panel", "Vacuum dust from the blades", "Reassemble and restore power"]),
        HMASeedTask(title: "Check Outdoor Clearance", detail: "Keep plants and clutter away from the condenser.", difficulty: .easy, frequency: .seasonal, minutes: 15, tools: "Pruners", safety: "Maintain 60 cm clearance on all sides.", steps: ["Inspect around the unit", "Trim back vegetation", "Remove leaves and clutter", "Confirm clear airflow"]),
        HMASeedTask(title: "Inspect Furnace Flame", detail: "A clean blue flame indicates safe combustion.", difficulty: .moderate, frequency: .annual, minutes: 20, tools: "Flashlight", safety: "A yellow flame may mean carbon monoxide; call a pro.", steps: ["Observe the burner flame", "Confirm a steady blue colour", "Note yellow or flickering flames", "Schedule service if abnormal"]),
        HMASeedTask(title: "Replace Thermostat Schedule", detail: "Update programming for the season to save energy.", difficulty: .easy, frequency: .seasonal, minutes: 15, tools: "None", safety: "None.", steps: ["Open the thermostat schedule", "Set seasonal temperatures", "Confirm away and sleep periods", "Save the program"])
    ]

    // MARK: - Electrical

    private static let HMAelectricalTasks: [HMASeedTask] = [
        HMASeedTask(title: "Test GFCI Outlets", detail: "Ground-fault outlets must trip to prevent shock.", difficulty: .easy, frequency: .quarterly, minutes: 15, tools: "None", safety: "Replace any outlet that fails to trip or reset.", steps: ["Press TEST on each GFCI", "Confirm power cuts off", "Press RESET", "Verify power returns"]),
        HMASeedTask(title: "Check Smoke Detector", detail: "Working smoke alarms are essential life safety devices.", difficulty: .easy, frequency: .monthly, minutes: 10, tools: "Replacement battery", safety: "Never disable a smoke alarm.", steps: ["Press and hold the test button", "Confirm a loud alarm", "Replace the battery if weak", "Vacuum the unit"]),
        HMASeedTask(title: "Test Carbon Monoxide Alarm", detail: "CO alarms warn of a colourless, deadly gas.", difficulty: .easy, frequency: .monthly, minutes: 10, tools: "Replacement battery", safety: "Evacuate and call emergency services on a real CO alarm.", steps: ["Press the test button", "Confirm the alarm sounds", "Replace batteries as needed", "Check the expiry date"]),
        HMASeedTask(title: "Inspect Electrical Panel", detail: "Look for warm breakers, rust or scorching.", difficulty: .moderate, frequency: .biannual, minutes: 20, tools: "Flashlight", safety: "Do not remove the panel cover; call an electrician for issues.", steps: ["Open the panel door", "Check breaker labels", "Feel for warmth without touching bus bars", "Note rust or burning smells"]),
        HMASeedTask(title: "Test Tripped Breakers", detail: "Confirm breakers reset and hold under load.", difficulty: .easy, frequency: .biannual, minutes: 15, tools: "None", safety: "A breaker that trips repeatedly needs an electrician.", steps: ["Identify any tripped breakers", "Switch fully off then on", "Confirm power restores", "Log breakers that keep tripping"]),
        HMASeedTask(title: "Inspect Extension Cords", detail: "Damaged cords are a fire and shock hazard.", difficulty: .easy, frequency: .quarterly, minutes: 15, tools: "None", safety: "Discard frayed or hot cords immediately.", steps: ["Inspect cords for fraying", "Feel for warm spots", "Confirm correct ratings", "Replace damaged cords"]),
        HMASeedTask(title: "Check Outlet Faceplates", detail: "Loose or warm outlets indicate wiring problems.", difficulty: .easy, frequency: .biannual, minutes: 20, tools: "Screwdriver, outlet tester", safety: "Stop if an outlet is warm or sparks; call a pro.", steps: ["Inspect each faceplate", "Plug in an outlet tester", "Confirm correct wiring", "Flag warm outlets"]),
        HMASeedTask(title: "Test Light Switches", detail: "Flickering or warm switches need attention.", difficulty: .easy, frequency: .biannual, minutes: 15, tools: "None", safety: "Avoid switches that buzz or feel hot.", steps: ["Cycle each switch", "Note flickering lights", "Feel for warmth", "Flag faulty switches"]),
        HMASeedTask(title: "Inspect Light Fixtures", detail: "Confirm bulbs match fixture ratings to avoid overheating.", difficulty: .easy, frequency: .biannual, minutes: 20, tools: "Replacement bulbs", safety: "Let hot bulbs cool before handling.", steps: ["Check wattage ratings", "Replace mismatched bulbs", "Tighten loose fixtures", "Clean shades"]),
        HMASeedTask(title: "Label Breaker Panel", detail: "Accurate labels speed up emergencies.", difficulty: .easy, frequency: .annual, minutes: 30, tools: "Labels, helper", safety: "Work with a helper and avoid the bus bars.", steps: ["Map each breaker to a circuit", "Have a helper confirm", "Apply clear labels", "Document the layout"]),
        HMASeedTask(title: "Test Surge Protectors", detail: "Surge protectors degrade over time and stop protecting.", difficulty: .easy, frequency: .annual, minutes: 15, tools: "Replacement protector", safety: "Do not daisy-chain power strips.", steps: ["Check the protection indicator light", "Confirm a recent purchase date", "Replace aged units", "Verify proper grounding"]),
        HMASeedTask(title: "Inspect Doorbell Wiring", detail: "Fix intermittent doorbells at the transformer or button.", difficulty: .moderate, frequency: .annual, minutes: 25, tools: "Screwdriver, multimeter", safety: "Low-voltage, but cut power if unsure.", steps: ["Test the doorbell button", "Inspect wiring connections", "Check the transformer voltage", "Replace faulty parts"])
    ]

    // MARK: - Plumbing

    private static let HMAplumbingTasks: [HMASeedTask] = [
        HMASeedTask(title: "Water Heater Flush", detail: "Drain sediment to keep the heater efficient and quiet.", difficulty: .moderate, frequency: .annual, minutes: 60, tools: "Garden hose, gloves", safety: "Water is scalding hot; shut off power or gas first.", steps: ["Turn off power or gas to the heater", "Connect a hose to the drain valve", "Drain until the water runs clear", "Refill and restore power"]),
        HMASeedTask(title: "Check for Plumbing Leaks", detail: "Find drips under sinks and at supply lines early.", difficulty: .easy, frequency: .quarterly, minutes: 30, tools: "Flashlight, paper towel", safety: "Address active leaks before they spread.", steps: ["Inspect under each sink", "Wrap fittings with paper towel to spot drips", "Check supply line connections", "Tighten or replace as needed"]),
        HMASeedTask(title: "Test Main Water Shutoff", detail: "Confirm you can stop all water in an emergency.", difficulty: .easy, frequency: .annual, minutes: 15, tools: "None", safety: "Do not force a seized valve; call a plumber.", steps: ["Locate the main shutoff valve", "Turn it fully closed", "Confirm taps stop flowing", "Reopen the valve"]),
        HMASeedTask(title: "Inspect Water Heater T&P Valve", detail: "The relief valve prevents dangerous pressure buildup.", difficulty: .moderate, frequency: .annual, minutes: 20, tools: "Bucket", safety: "Discharge water is scalding; keep hands clear.", steps: ["Place a bucket under the discharge", "Lift the valve lever briefly", "Confirm water flows then stops", "Replace the valve if it leaks"]),
        HMASeedTask(title: "Clear Slow Drains", detail: "Maintain free-flowing drains without harsh chemicals.", difficulty: .easy, frequency: .quarterly, minutes: 20, tools: "Drain snake, baking soda, vinegar", safety: "Avoid chemical cleaners that damage pipes.", steps: ["Remove visible debris", "Use a drain snake on clogs", "Flush with baking soda and vinegar", "Rinse with hot water"]),
        HMASeedTask(title: "Inspect Washing Machine Hoses", detail: "Burst hoses are a leading cause of water damage.", difficulty: .easy, frequency: .biannual, minutes: 20, tools: "None", safety: "Replace rubber hoses every five years.", steps: ["Pull the machine out", "Inspect hoses for bulging or cracks", "Check connections for drips", "Replace aged hoses"]),
        HMASeedTask(title: "Check Toilet Fill Valve", detail: "A noisy or running fill valve wastes water.", difficulty: .easy, frequency: .biannual, minutes: 20, tools: "Replacement valve (if needed)", safety: "Shut off the supply before service.", steps: ["Remove the tank lid", "Watch the fill cycle", "Adjust the water level", "Replace a faulty valve"]),
        HMASeedTask(title: "Insulate Exposed Pipes", detail: "Pipe insulation prevents freezing and heat loss.", difficulty: .easy, frequency: .annual, minutes: 30, tools: "Pipe insulation, tape", safety: "Mind sharp edges in crawlspaces.", steps: ["Identify exposed pipes", "Measure and cut insulation", "Wrap and secure it", "Seal seams with tape"]),
        HMASeedTask(title: "Inspect Sump Pump", detail: "Confirm the pump runs before the rainy season.", difficulty: .moderate, frequency: .biannual, minutes: 25, tools: "Bucket of water", safety: "Unplug before reaching into the pit.", steps: ["Pour water into the sump pit", "Confirm the pump activates", "Verify it drains and shuts off", "Clean the inlet screen"]),
        HMASeedTask(title: "Check Hose Bib Backflow", detail: "Backflow preventers keep outdoor water from siphoning back.", difficulty: .easy, frequency: .annual, minutes: 15, tools: "Wrench", safety: "Hand-tighten to avoid damaging threads.", steps: ["Inspect the backflow device", "Confirm it is intact", "Tighten if loose", "Test water flow"]),
        HMASeedTask(title: "Service Faucet Cartridge", detail: "A worn cartridge causes drips and temperature drift.", difficulty: .moderate, frequency: .annual, minutes: 40, tools: "Cartridge kit, hex key", safety: "Shut off supply valves first.", steps: ["Close the supply valves", "Remove the handle and cartridge", "Install a new cartridge", "Reassemble and test"]),
        HMASeedTask(title: "Inspect Water Pressure", detail: "High pressure stresses pipes and fixtures.", difficulty: .easy, frequency: .annual, minutes: 15, tools: "Pressure gauge", safety: "Pressure above 80 psi needs a regulator.", steps: ["Attach a gauge to a hose bib", "Open the tap and read pressure", "Confirm it is within range", "Adjust the regulator if needed"])
    ]
}
