//
//  QuestionBank.swift
//  TLCExamAce
//
//  Seed data: 60+ real TLC exam questions
//

import Foundation

// MARK: - Question Bank
final class QuestionBank {
    static let shared = QuestionBank()
    private(set) var allQuestions: [Question] = []

    private init() {
        allQuestions = Self.buildQuestions()
    }

    func questions(for category: QuestionCategory? = nil,
                   licenseType: LicenseType = .all,
                   difficulty: Difficulty? = nil,
                   limit: Int? = nil) -> [Question] {
        var filtered = allQuestions

        if let category {
            filtered = filtered.filter { $0.category == category }
        }

        if licenseType != .all {
            filtered = filtered.filter {
                $0.licenseTypes.contains(licenseType) || $0.licenseTypes.contains(.all)
            }
        }

        if let difficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }

        filtered.shuffle()

        if let limit {
            return Array(filtered.prefix(limit))
        }
        return filtered
    }

    func weakAreaQuestions(weak categories: [QuestionCategory], limit: Int = 20) -> [Question] {
        let weakQs = allQuestions.filter { categories.contains($0.category) }
        return Array(weakQs.shuffled().prefix(limit))
    }

    func question(by id: UUID) -> Question? {
        allQuestions.first { $0.id == id }
    }

    // MARK: - Question Seed Data
    private static func buildQuestions() -> [Question] {
        var questions: [Question] = []

        // MARK: NYC Geography (15 questions)
        questions += [
            Question(
                text: "How many boroughs does New York City have?",
                options: ["3", "4", "5", "6"],
                correctIndex: 2,
                explanation: "NYC has 5 boroughs: Manhattan, Brooklyn, Queens, the Bronx, and Staten Island.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["boroughs", "basics"]
            ),
            Question(
                text: "Which bridge connects Manhattan to Brooklyn?",
                options: ["Verrazano-Narrows Bridge", "Brooklyn Bridge", "George Washington Bridge", "Queensboro Bridge"],
                correctIndex: 1,
                explanation: "The Brooklyn Bridge connects Lower Manhattan to DUMBO/Brooklyn Heights in Brooklyn.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["bridges", "Manhattan", "Brooklyn"]
            ),
            Question(
                text: "What is the name of the tunnel that connects Manhattan to New Jersey under the Hudson River?",
                options: ["Brooklyn-Battery Tunnel", "Queens-Midtown Tunnel", "Lincoln Tunnel", "Williamsburg Tunnel"],
                correctIndex: 2,
                explanation: "The Lincoln Tunnel connects Midtown Manhattan to Weehawken, New Jersey. The Holland Tunnel also connects to NJ but Lincoln is the most well-known.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["tunnels", "Manhattan", "New Jersey"]
            ),
            Question(
                text: "JFK International Airport is located in which borough?",
                options: ["Manhattan", "The Bronx", "Staten Island", "Queens"],
                correctIndex: 3,
                explanation: "John F. Kennedy International Airport (JFK) is located in the Jamaica neighborhood of Queens.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["airports", "Queens", "JFK"]
            ),
            Question(
                text: "LaGuardia Airport is located in which neighborhood?",
                options: ["Flushing, Queens", "East Elmhurst, Queens", "Jamaica, Queens", "Long Island City, Queens"],
                correctIndex: 1,
                explanation: "LaGuardia Airport (LGA) is located in East Elmhurst, Queens.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["airports", "Queens", "LaGuardia"]
            ),
            Question(
                text: "Which of the following is NOT a Manhattan neighborhood?",
                options: ["SoHo", "Tribeca", "Astoria", "Harlem"],
                correctIndex: 2,
                explanation: "Astoria is a neighborhood in Queens. SoHo, Tribeca, and Harlem are all in Manhattan.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["neighborhoods", "Manhattan", "Queens"]
            ),
            Question(
                text: "The Verrazano-Narrows Bridge connects which two boroughs?",
                options: ["Manhattan and Brooklyn", "Brooklyn and Queens", "Staten Island and Brooklyn", "Staten Island and Manhattan"],
                correctIndex: 2,
                explanation: "The Verrazano-Narrows Bridge connects Staten Island to the Bay Ridge neighborhood of Brooklyn.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["bridges", "Staten Island", "Brooklyn"]
            ),
            Question(
                text: "What is the major highway that runs along the East Side of Manhattan?",
                options: ["West Side Highway", "FDR Drive", "Belt Parkway", "Brooklyn-Queens Expressway"],
                correctIndex: 1,
                explanation: "The FDR Drive (Franklin D. Roosevelt East River Drive) runs along the eastern waterfront of Manhattan.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["highways", "Manhattan", "FDR"]
            ),
            Question(
                text: "Grand Central Terminal is located on which street in Manhattan?",
                options: ["34th Street", "42nd Street", "57th Street", "72nd Street"],
                correctIndex: 1,
                explanation: "Grand Central Terminal is located at 42nd Street and Park Avenue in Midtown Manhattan.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["landmarks", "Manhattan", "Grand Central"]
            ),
            Question(
                text: "Which borough is connected to Manhattan only by bridges or tunnels (no direct land connection)?",
                options: ["The Bronx", "Brooklyn", "Queens", "Staten Island"],
                correctIndex: 3,
                explanation: "Staten Island is the only borough with no subway connection to Manhattan and requires a ferry, bridge (Goethals, Bayonne, Outerbridge) or the Verrazano to Brooklyn.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .hard,
                tags: ["boroughs", "Staten Island"]
            ),
            Question(
                text: "What is the address range of 'Midtown Manhattan'?",
                options: ["1st St to 14th St", "14th St to 34th St", "34th St to 59th St", "59th St to 96th St"],
                correctIndex: 2,
                explanation: "Midtown Manhattan generally refers to the area between 34th Street and 59th Street.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["Manhattan", "streets"]
            ),
            Question(
                text: "The Queens-Midtown Tunnel connects Midtown Manhattan to which neighborhood in Queens?",
                options: ["Astoria", "Long Island City", "Flushing", "Jamaica"],
                correctIndex: 1,
                explanation: "The Queens-Midtown Tunnel connects East Midtown Manhattan (34th-37th St) to Long Island City in Queens.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .hard,
                tags: ["tunnels", "Queens", "Manhattan"]
            ),
            Question(
                text: "Which of the following airports serves domestic flights primarily and is closest to Midtown Manhattan?",
                options: ["JFK", "Newark Liberty", "LaGuardia", "Stewart International"],
                correctIndex: 2,
                explanation: "LaGuardia Airport is the closest major airport to Midtown Manhattan, approximately 8 miles away.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["airports", "distance"]
            ),
            Question(
                text: "What is the name of the major street that divides Manhattan's East Side from its West Side?",
                options: ["Broadway", "Fifth Avenue", "Park Avenue", "Lexington Avenue"],
                correctIndex: 1,
                explanation: "Fifth Avenue is the dividing line between the East Side and West Side of Manhattan, with street addresses designated East or West accordingly.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["streets", "Manhattan"]
            ),
            Question(
                text: "The Staten Island Ferry travels between which two points?",
                options: ["St. George Terminal and Whitehall Terminal", "St. George Terminal and Battery Park", "Tottenville and Bay Ridge", "St. George and Governors Island"],
                correctIndex: 0,
                explanation: "The Staten Island Ferry travels between the St. George Ferry Terminal in Staten Island and the Whitehall Ferry Terminal in Lower Manhattan.",
                category: .nycGeography,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["Staten Island", "ferry", "Manhattan"]
            ),

            // MARK: TLC Regulations (20 questions)
            Question(
                text: "What is the maximum number of passengers allowed in a standard FHV (For-Hire Vehicle)?",
                options: ["4", "5", "6", "7"],
                correctIndex: 1,
                explanation: "A standard FHV may carry a maximum of 5 passengers. Larger vehicles may carry more with appropriate licensing.",
                category: .tlcRegulations,
                licenseTypes: [.fhv],
                difficulty: .easy,
                tags: ["passengers", "FHV", "rules"]
            ),
            Question(
                text: "How often must TLC-licensed drivers renew their driver's license?",
                options: ["Every year", "Every 2 years", "Every 3 years", "Every 4 years"],
                correctIndex: 1,
                explanation: "TLC driver licenses must be renewed every two years.",
                category: .tlcRegulations,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["renewal", "license"]
            ),
            Question(
                text: "A TLC driver must report a change of address to the TLC within how many days?",
                options: ["7 days", "10 days", "30 days", "60 days"],
                correctIndex: 1,
                explanation: "TLC drivers must notify the TLC of any change of address within 10 business days.",
                category: .tlcRegulations,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["address", "notification", "rules"]
            ),
            Question(
                text: "Which document must a TLC driver always have in their vehicle while working?",
                options: ["Only the vehicle registration", "TLC driver license and vehicle license", "Only the TLC driver license", "Personal driver's license only"],
                correctIndex: 1,
                explanation: "Drivers must have both their TLC driver license and the vehicle's TLC license while operating.",
                category: .tlcRegulations,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["documents", "required"]
            ),
            Question(
                text: "What is the minimum age requirement to apply for a TLC driver license?",
                options: ["16", "18", "19", "21"],
                correctIndex: 2,
                explanation: "Applicants must be at least 19 years old to apply for a TLC driver license.",
                category: .tlcRegulations,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["age", "requirements"]
            ),
            Question(
                text: "A driver may NOT pick up street hails (unscheduled passengers) if they have which type of TLC license?",
                options: ["Yellow Taxi License", "LPEP License", "FHV License", "Both B and C"],
                correctIndex: 2,
                explanation: "FHV (For-Hire Vehicle) drivers may only pick up pre-arranged rides and cannot respond to street hails. Only yellow taxi and LPEP (green taxi) drivers can pick up street hails.",
                category: .tlcRegulations,
                licenseTypes: [.fhv],
                difficulty: .medium,
                tags: ["street hail", "FHV", "rules"]
            ),
            Question(
                text: "LPEP stands for:",
                options: ["Licensed Professional Exclusive Provider", "Livery Provider Extension Program", "Licensed Passenger Equipment Platform", "Low Performance Engine Program"],
                correctIndex: 1,
                explanation: "LPEP stands for Livery Provider Extension Program - the technology platforms used by green taxi (boro taxi) drivers.",
                category: .tlcRegulations,
                licenseTypes: [.lpep],
                difficulty: .hard,
                tags: ["LPEP", "green taxi", "definitions"]
            ),
            Question(
                text: "What must a TLC driver do if they receive a summons from a TLC inspector?",
                options: ["Ignore it if they believe it is wrong", "Pay the fine immediately by mail", "Appear at the scheduled hearing", "Contact their insurance company"],
                correctIndex: 2,
                explanation: "Drivers must appear at the TLC hearing scheduled on the summons. Failure to appear results in a default judgment and additional penalties.",
                category: .tlcRegulations,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["summons", "hearings"]
            ),
            Question(
                text: "A TLC driver is required to accept passengers going to any destination within:",
                options: ["Manhattan only", "The 5 boroughs", "New York State", "The Tri-State area"],
                correctIndex: 1,
                explanation: "Yellow taxi and LPEP drivers must accept all trips within New York City's 5 boroughs. FHV trips are pre-arranged and destination-agnostic.",
                category: .tlcRegulations,
                licenseTypes: [.taxi, .lpep],
                difficulty: .medium,
                tags: ["destinations", "service area"]
            ),
            Question(
                text: "What is the maximum fine for a first offense of operating without a valid TLC license?",
                options: ["$100", "$500", "$1,000", "$2,000"],
                correctIndex: 2,
                explanation: "The maximum fine for operating a for-hire vehicle without a valid TLC license is $1,000 for a first offense.",
                category: .tlcRegulations,
                licenseTypes: [.all],
                difficulty: .hard,
                tags: ["fines", "penalties"]
            ),
            Question(
                text: "Under TLC rules, smoking is:",
                options: ["Allowed with passenger permission", "Allowed with windows open", "Never allowed in a TLC vehicle", "Allowed only for the driver"],
                correctIndex: 2,
                explanation: "Smoking is prohibited at all times in TLC-licensed vehicles, regardless of whether a passenger is present.",
                category: .tlcRegulations,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["smoking", "vehicle rules"]
            ),
            Question(
                text: "A yellow taxi driver must accept a passenger going to which of the following destinations?",
                options: ["Newark Airport only if agreed before the trip", "Any destination in the 5 boroughs", "Manhattan only", "Destinations within 15 miles"],
                correctIndex: 1,
                explanation: "Yellow taxi drivers must accept all trips to any destination within the 5 boroughs. Refusing a passenger based on destination is a violation.",
                category: .tlcRegulations,
                licenseTypes: [.taxi],
                difficulty: .medium,
                tags: ["refusal", "destinations", "taxi"]
            ),
            Question(
                text: "What type of background check is required for all new TLC driver applicants?",
                options: ["State criminal background check only", "FBI fingerprint-based background check", "Local police report only", "Credit check"],
                correctIndex: 1,
                explanation: "All TLC applicants must undergo an FBI fingerprint-based background check through the New York State Division of Criminal Justice Services.",
                category: .tlcRegulations,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["background check", "application"]
            ),
            Question(
                text: "Green taxis (LPEP) may pick up street hails in which areas?",
                options: ["All of NYC", "Manhattan only below 96th St", "Manhattan above 96th St and outer boroughs", "Outer boroughs only"],
                correctIndex: 2,
                explanation: "Green taxis (Boro Taxis) may pick up street hails in Manhattan above 96th Street and in all outer boroughs. They cannot pick up street hails in Manhattan south of 96th Street.",
                category: .tlcRegulations,
                licenseTypes: [.lpep],
                difficulty: .hard,
                tags: ["green taxi", "LPEP", "street hail", "zones"]
            ),
            Question(
                text: "If a passenger leaves property in a yellow taxi, the driver must:",
                options: ["Keep it for 24 hours then discard", "Turn it in to any NYPD precinct", "Submit a lost property report to the TLC within 24 hours", "Contact their base for instructions"],
                correctIndex: 2,
                explanation: "Yellow taxi drivers must submit a lost property report to the TLC within 24 hours and bring the property to the TLC's lost property office.",
                category: .tlcRegulations,
                licenseTypes: [.taxi],
                difficulty: .medium,
                tags: ["lost property", "passenger service"]
            ),
            Question(
                text: "TLC drivers must carry which type of insurance at minimum?",
                options: ["Personal auto insurance", "Commercial TLC-approved insurance", "State minimum liability", "No insurance is required if leasing"],
                correctIndex: 1,
                explanation: "All TLC vehicles must be covered by TLC-approved commercial automobile liability insurance meeting minimum requirements.",
                category: .tlcRegulations,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["insurance", "requirements"]
            ),
            Question(
                text: "What must a TLC driver do if they are involved in an accident resulting in injury?",
                options: ["File a report only if they are at fault", "Leave the scene if no one is seriously hurt", "Remain at scene, call 911, and file a TLC accident report", "Only file a report if property damage exceeds $1,000"],
                correctIndex: 2,
                explanation: "Drivers must remain at the scene, call 911, render assistance, and file a TLC accident report within 24 hours of any accident involving injury or significant property damage.",
                category: .tlcRegulations,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["accidents", "reporting"]
            ),
            Question(
                text: "Under TLC regulations, a driver may not discriminate based on a passenger's:",
                options: ["Destination only", "Race, religion, national origin, disability, or any protected class", "Age only", "Payment method"],
                correctIndex: 1,
                explanation: "TLC regulations prohibit discrimination based on any protected class including race, color, creed, religion, national origin, gender, sexual orientation, age, disability, or any other protected characteristic.",
                category: .tlcRegulations,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["discrimination", "civil rights"]
            ),
            Question(
                text: "How long must TLC drivers maintain records of completed trips?",
                options: ["6 months", "1 year", "3 years", "5 years"],
                correctIndex: 1,
                explanation: "TLC drivers must maintain trip records for a minimum of 1 year.",
                category: .tlcRegulations,
                licenseTypes: [.all],
                difficulty: .hard,
                tags: ["records", "documentation"]
            ),
            Question(
                text: "A TLC vehicle license (medallion for taxis) is:",
                options: ["Transferable to any driver", "Assigned to the vehicle, not the driver", "Assigned only to the registered owner", "Valid only in Manhattan"],
                correctIndex: 1,
                explanation: "The TLC vehicle license is issued for a specific vehicle. A driver needs both a valid driver's TLC license and must operate a separately-licensed TLC vehicle.",
                category: .tlcRegulations,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["vehicle license", "medallion"]
            ),

            // MARK: Traffic Laws (10 questions)
            Question(
                text: "In New York City, what is the default speed limit unless otherwise posted?",
                options: ["20 mph", "25 mph", "30 mph", "35 mph"],
                correctIndex: 1,
                explanation: "New York City lowered its default speed limit from 30 mph to 25 mph in November 2014.",
                category: .trafficLaws,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["speed limit", "NYC law"]
            ),
            Question(
                text: "What is the speed limit in a NYC school zone when children are present?",
                options: ["15 mph", "20 mph", "25 mph", "30 mph"],
                correctIndex: 1,
                explanation: "The speed limit in a NYC school zone when children are present is 20 mph.",
                category: .trafficLaws,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["school zone", "speed limit"]
            ),
            Question(
                text: "In NYC, when approaching a red light, you may turn right after stopping unless:",
                options: ["There is a 'No Turn on Red' sign", "It is nighttime", "The speed limit is over 25 mph", "You are in a taxi"],
                correctIndex: 0,
                explanation: "Right turns on red are not permitted in New York City unless a specific 'Right Turn Permitted on Red' sign is posted. NYC has a general prohibition on red light turns.",
                category: .trafficLaws,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["red light", "turning", "NYC rules"]
            ),
            Question(
                text: "A double solid yellow line in the center of the road means:",
                options: ["Passing is allowed from both directions", "Passing is allowed only from the right side", "No passing from either direction", "Parking is prohibited on both sides"],
                correctIndex: 2,
                explanation: "A double solid yellow center line means passing is prohibited from either direction.",
                category: .trafficLaws,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["road markings", "passing"]
            ),
            Question(
                text: "When must you yield to a pedestrian in a crosswalk?",
                options: ["Only when the pedestrian has the walk signal", "Only in school zones", "Always, whether or not there is a signal", "Only during daylight hours"],
                correctIndex: 2,
                explanation: "Drivers must always yield to pedestrians in crosswalks, whether marked or unmarked, regardless of signal status.",
                category: .trafficLaws,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["pedestrians", "crosswalk", "yield"]
            ),
            Question(
                text: "What does a flashing yellow traffic light mean?",
                options: ["Stop and proceed when clear", "Proceed with caution", "The light is about to turn red", "Yield to all traffic"],
                correctIndex: 1,
                explanation: "A flashing yellow light means proceed with caution. Slow down and be aware of crossing traffic.",
                category: .trafficLaws,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["traffic signals", "yellow light"]
            ),
            Question(
                text: "In NYC, it is illegal to use a handheld cell phone while driving. The fine for a first offense is approximately:",
                options: ["$50", "$100", "$200", "$500"],
                correctIndex: 2,
                explanation: "The base fine for using a handheld electronic device while driving in New York is $100-$250 plus surcharges, totaling approximately $200+ for a first offense.",
                category: .trafficLaws,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["cell phone", "distracted driving", "fines"]
            ),
            Question(
                text: "When parallel parking, your vehicle must be no more than how far from the curb?",
                options: ["6 inches", "12 inches", "18 inches", "24 inches"],
                correctIndex: 1,
                explanation: "When parallel parking in New York, your vehicle must be within 12 inches of the curb.",
                category: .trafficLaws,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["parking", "curb"]
            ),
            Question(
                text: "What is the minimum following distance (in car lengths) recommended at speeds over 30 mph?",
                options: ["1 car length", "2 car lengths", "3 car lengths", "4 car lengths"],
                correctIndex: 2,
                explanation: "The 3-second (minimum 3 car length) following distance rule is recommended at speeds over 30 mph.",
                category: .trafficLaws,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["following distance", "safety"]
            ),
            Question(
                text: "In New York, you must use headlights:",
                options: ["Only at night", "From sunset to sunrise and when visibility is less than 1,000 feet", "Only in tunnels", "Whenever it rains"],
                correctIndex: 1,
                explanation: "New York law requires headlights from sunset to sunrise and whenever visibility is less than 1,000 feet due to weather or other conditions.",
                category: .trafficLaws,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["headlights", "visibility"]
            ),

            // MARK: Defensive Driving (8 questions)
            Question(
                text: "What is the primary goal of defensive driving?",
                options: ["To drive as fast as legally possible", "To anticipate hazards and reduce the risk of accidents", "To avoid all traffic", "To follow other vehicles closely"],
                correctIndex: 1,
                explanation: "Defensive driving means anticipating potential hazards, staying alert, and taking actions to reduce risk - protecting yourself and others.",
                category: .defensiveDriving,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["defensive driving", "safety philosophy"]
            ),
            Question(
                text: "The 'Smith System' of defensive driving recommends scanning how far ahead while driving on a highway?",
                options: ["5 seconds ahead", "8-12 seconds ahead", "15-20 seconds ahead", "30 seconds ahead"],
                correctIndex: 2,
                explanation: "The Smith System recommends aiming your eyes 15-20 seconds ahead on highways (about 1/4 mile at highway speeds) to give yourself time to react.",
                category: .defensiveDriving,
                licenseTypes: [.all],
                difficulty: .hard,
                tags: ["Smith System", "scanning", "awareness"]
            ),
            Question(
                text: "When should you check your mirrors while driving?",
                options: ["Only when changing lanes", "Every 5-8 seconds", "Only when stopping", "Every 20-30 seconds"],
                correctIndex: 1,
                explanation: "Professional drivers should check their mirrors every 5-8 seconds to maintain full awareness of surrounding traffic.",
                category: .defensiveDriving,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["mirrors", "scanning"]
            ),
            Question(
                text: "If you feel drowsy while driving, what should you do?",
                options: ["Open the window and continue", "Turn up the music", "Pull over safely and rest", "Drink coffee and continue"],
                correctIndex: 2,
                explanation: "The only safe solution for drowsy driving is to stop and rest. Opening windows or drinking coffee are temporary measures that do not effectively combat drowsiness.",
                category: .defensiveDriving,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["fatigue", "safety"]
            ),
            Question(
                text: "When driving in heavy rain, what should you do to your speed?",
                options: ["Maintain the posted speed limit", "Increase speed to get through rain faster", "Reduce speed by at least 1/3", "Reduce speed only if visibility is near zero"],
                correctIndex: 2,
                explanation: "In heavy rain, you should reduce your speed by at least one-third of the posted limit to maintain safe stopping distances and prevent hydroplaning.",
                category: .defensiveDriving,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["weather", "rain", "speed"]
            ),
            Question(
                text: "What is 'hydroplaning'?",
                options: ["Driving through flood waters", "Losing tire traction due to water between tires and road", "Using water to cool the engine", "A type of skid on ice"],
                correctIndex: 1,
                explanation: "Hydroplaning occurs when a layer of water builds up between the tires and road surface, causing the driver to lose control. It typically occurs at speeds above 35 mph in wet conditions.",
                category: .defensiveDriving,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["hydroplaning", "rain", "traction"]
            ),
            Question(
                text: "A driver can minimize the danger of being in another vehicle's blind spot by:",
                options: ["Honking their horn", "Passing quickly or falling behind", "Flashing headlights", "Staying in the blind spot and watching carefully"],
                correctIndex: 1,
                explanation: "To minimize time in another vehicle's blind spot, either accelerate to pass the vehicle completely or fall back so you are visible in their mirrors.",
                category: .defensiveDriving,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["blind spots", "passing"]
            ),
            Question(
                text: "What should you do if your vehicle goes into a skid?",
                options: ["Brake hard and turn sharply", "Accelerate to regain traction", "Steer in the direction you want to go and ease off the gas", "Pull the handbrake"],
                correctIndex: 2,
                explanation: "If you skid, take your foot off the gas and steer in the direction you want the vehicle to go. Avoid braking hard, which can make the skid worse.",
                category: .defensiveDriving,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["skid", "emergency"]
            ),

            // MARK: Vehicle Inspection (5 questions)
            Question(
                text: "How often must TLC-licensed vehicles undergo a safety inspection?",
                options: ["Once per year", "Every 6 months", "Every 4 months", "Every 3 months"],
                correctIndex: 2,
                explanation: "TLC-licensed vehicles must pass a TLC vehicle inspection every 4 months (3 times per year).",
                category: .vehicleInspection,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["inspection", "vehicle maintenance"]
            ),
            Question(
                text: "What happens if a TLC vehicle fails its safety inspection?",
                options: ["The driver can continue operating for 30 days", "The vehicle license is suspended until repairs are made and vehicle passes re-inspection", "The driver receives a warning for the first failure", "Nothing — the driver can appeal without stopping operations"],
                correctIndex: 1,
                explanation: "A vehicle that fails TLC inspection has its vehicle license suspended. The vehicle cannot be operated until repairs are completed and it passes a re-inspection.",
                category: .vehicleInspection,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["inspection", "failure", "suspension"]
            ),
            Question(
                text: "Which of the following is checked during a TLC vehicle inspection?",
                options: ["Only tires and brakes", "Only emissions", "Brakes, tires, lights, horn, and other safety equipment", "Only the vehicle identification number (VIN)"],
                correctIndex: 2,
                explanation: "TLC vehicle inspections cover comprehensive safety items including brakes, tires, lights, horn, windshield wipers, mirrors, seatbelts, and other safety-critical equipment.",
                category: .vehicleInspection,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["inspection items", "vehicle safety"]
            ),
            Question(
                text: "Before starting a shift, a TLC driver should perform a:",
                options: ["Full mechanical overhaul", "Pre-trip vehicle inspection", "Oil change", "Tire rotation"],
                correctIndex: 1,
                explanation: "Professional drivers should perform a pre-trip inspection before each shift, checking tires, lights, mirrors, brakes, fluids, and ensuring the vehicle is safe to operate.",
                category: .vehicleInspection,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["pre-trip", "daily inspection"]
            ),
            Question(
                text: "Tread depth on tires must be at least:",
                options: ["1/16 inch (1.6mm)", "2/32 inch (1.6mm)", "4/32 inch (3.2mm)", "6/32 inch (4.8mm)"],
                correctIndex: 1,
                explanation: "New York State requires a minimum tread depth of 2/32 inch (1.6mm), but TLC may have stricter requirements. Replace tires showing significant wear.",
                category: .vehicleInspection,
                licenseTypes: [.all],
                difficulty: .hard,
                tags: ["tires", "tread depth"]
            ),

            // MARK: Customer Service (5 questions)
            Question(
                text: "If a passenger asks you to turn down the music, you should:",
                options: ["Explain it's your vehicle and your choice", "Comply immediately and professionally", "Turn it down slightly but not off", "Ask the passenger to pay extra"],
                correctIndex: 1,
                explanation: "TLC regulations require drivers to comply with reasonable passenger requests regarding vehicle environment. Professional service requires accommodating passengers.",
                category: .customerService,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["music", "passenger requests"]
            ),
            Question(
                text: "A passenger who is blind boards your taxi with a guide dog. You should:",
                options: ["Refuse the trip as animals are not allowed", "Accept the trip — guide dogs must be accommodated", "Charge an extra fee for the animal", "Only accept if the dog fits in the trunk"],
                correctIndex: 1,
                explanation: "Under the ADA and NYC Human Rights Law, service animals including guide dogs must be accommodated in all TLC vehicles at no additional charge. Refusing a passenger with a service animal is a serious violation.",
                category: .customerService,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["ADA", "service animals", "accessibility"]
            ),
            Question(
                text: "A passenger pays with a credit card. The driver may:",
                options: ["Refuse credit cards and demand cash", "Charge a surcharge for credit card payment", "Accept the credit card at the metered rate with no surcharge", "Add a minimum 15% tip automatically"],
                correctIndex: 2,
                explanation: "Yellow taxis and many TLC vehicles are required to accept credit cards at the metered rate. No surcharges for credit card use are permitted.",
                category: .customerService,
                licenseTypes: [.taxi],
                difficulty: .medium,
                tags: ["payment", "credit card", "surcharge"]
            ),
            Question(
                text: "If a passenger threatens or assaults you, you should:",
                options: ["Physically restrain the passenger", "Continue driving and ignore the behavior", "Stop in a safe location and call 911", "Speed up to reach your destination faster"],
                correctIndex: 2,
                explanation: "If threatened or assaulted, stop safely as soon as possible and call 911. Your safety comes first. Document the incident and report it to the TLC.",
                category: .customerService,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["safety", "assault", "emergency"]
            ),
            Question(
                text: "A passenger has difficulty entering or exiting the vehicle. You should:",
                options: ["Wait in the vehicle until they manage", "Offer assistance if the passenger welcomes it", "Honk to rush them", "Only help if they ask and tip extra"],
                correctIndex: 1,
                explanation: "Drivers should proactively offer assistance to passengers who appear to have difficulty, while respecting the passenger's preference. This is both good customer service and required under accessibility guidelines.",
                category: .customerService,
                licenseTypes: [.all],
                difficulty: .easy,
                tags: ["accessibility", "assistance", "service"]
            ),

            // MARK: Accessibility (4 questions)
            Question(
                text: "A passenger using a wheelchair requests a trip. As an FHV driver without a wheelchair-accessible vehicle, you should:",
                options: ["Refuse the trip entirely", "Accept and help the passenger into the standard vehicle if they can transfer", "Ask them to find another driver", "Only accept if they pay double"],
                correctIndex: 1,
                explanation: "If the passenger is able to transfer and their wheelchair can be folded/stored, the driver should accommodate them. If the vehicle is not wheelchair accessible, the driver should help the passenger find an accessible vehicle through the dispatch system.",
                category: .accessibility,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["wheelchair", "ADA", "accessibility"]
            ),
            Question(
                text: "Under the ADA, a 'service animal' is defined as:",
                options: ["Any pet the passenger brings", "Only seeing-eye dogs", "A dog trained to perform tasks for a person with a disability", "Any animal certified by a vet"],
                correctIndex: 2,
                explanation: "Under the ADA, a service animal is specifically a dog (or in some cases a miniature horse) that has been individually trained to do work or perform tasks for a person with a disability.",
                category: .accessibility,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["ADA", "service animals", "definition"]
            ),
            Question(
                text: "NYC's Accessible Dispatch program provides wheelchair-accessible yellow taxis. Drivers who refuse a dispatch to a wheelchair user face:",
                options: ["A verbal warning", "No consequences for first refusal", "Fines and possible license suspension", "A mandatory retraining course"],
                correctIndex: 2,
                explanation: "Refusing accessible dispatch calls is a serious TLC violation that can result in significant fines and potential license suspension.",
                category: .accessibility,
                licenseTypes: [.taxi],
                difficulty: .hard,
                tags: ["accessible dispatch", "wheelchair", "penalties"]
            ),
            Question(
                text: "You may ask a person with a service animal which of the following questions?",
                options: ["What is your disability?", "Can you prove the animal is trained?", "Is this a service animal required because of a disability, and what task is it trained to perform?", "Do you have paperwork for the animal?"],
                correctIndex: 2,
                explanation: "Under ADA guidelines, you may only ask two questions: 1) Is this a service animal required because of a disability? 2) What work or task has the dog been trained to perform? You may not ask about the person's disability or demand documentation.",
                category: .accessibility,
                licenseTypes: [.all],
                difficulty: .hard,
                tags: ["service animals", "ADA", "questions"]
            ),

            // MARK: Insurance (3 questions)
            Question(
                text: "What minimum liability coverage is required for a TLC-licensed FHV?",
                options: ["$10,000/$20,000", "$25,000/$50,000", "$100,000/$300,000", "$1,000,000 combined"],
                correctIndex: 2,
                explanation: "TLC requires minimum liability coverage of $100,000 per person / $300,000 per incident for most FHV vehicles. Requirements vary by vehicle type.",
                category: .insurance,
                licenseTypes: [.fhv],
                difficulty: .hard,
                tags: ["insurance", "liability", "coverage amounts"]
            ),
            Question(
                text: "If your TLC insurance lapses, what happens to your TLC vehicle license?",
                options: ["Nothing until you have an accident", "It is automatically suspended", "You receive a 30-day grace period", "Only your driver license is affected"],
                correctIndex: 1,
                explanation: "If TLC insurance lapses, the vehicle license is automatically suspended. The vehicle cannot operate until insurance is reinstated and TLC is notified.",
                category: .insurance,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["insurance", "lapse", "suspension"]
            ),
            Question(
                text: "Personal auto insurance typically covers which of the following for TLC drivers?",
                options: ["All commercial trips", "Coverage while driving for hire", "Non-commercial personal use only", "All uses at all times"],
                correctIndex: 2,
                explanation: "Standard personal auto insurance generally excludes coverage while using the vehicle for commercial/for-hire purposes. TLC drivers must carry commercial insurance that covers their professional driving activities.",
                category: .insurance,
                licenseTypes: [.all],
                difficulty: .medium,
                tags: ["personal insurance", "commercial use", "coverage"]
            ),
        ]

        return questions
    }
}
