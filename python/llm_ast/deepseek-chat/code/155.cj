enum VehicleSize {
    MOTORCYCLE = 0,
    COMPACT = 1,
    LARGE = 2
}

class Vehicle {
    var vehicle_size: VehicleSize
    var license_plate: String
    var spot_size: Int
    var spots_taken: [ParkingSpot] = []

    init(vehicle_size: VehicleSize, license_plate: String, spot_size: Int) {
        self.vehicle_size = vehicle_size
        self.license_plate = license_plate
        self.spot_size = spot_size
    }

    func clear_spots() {
        for spot in spots_taken {
            spot.remove_vehicle(self)
        }
        spots_taken = []
    }

    func take_spot(spot: ParkingSpot) {
        spots_taken.append(spot)
    }

    func can_fit_in_spot(spot: ParkingSpot) -> Bool {
        // Abstract method, to be implemented by subclasses
        return false
    }
}

class Motorcycle: Vehicle {
    init(license_plate: String) {
        super.init(vehicle_size: .MOTORCYCLE, license_plate: license_plate, spot_size: 1)
    }

    override func can_fit_in_spot(spot: ParkingSpot) -> Bool {
        return true
    }
}

class Car: Vehicle {
    init(license_plate: String) {
        super.init(vehicle_size: .COMPACT, license_plate: license_plate, spot_size: 1)
    }

    override func can_fit_in_spot(spot: ParkingSpot) -> Bool {
        return spot.size == .LARGE || spot.size == .COMPACT
    }
}

class Bus: Vehicle {
    init(license_plate: String) {
        super.init(vehicle_size: .LARGE, license_plate: license_plate, spot_size: 5)
    }

    override func can_fit_in_spot(spot: ParkingSpot) -> Bool {
        return spot.size == .LARGE
    }
}

class ParkingLot {
    var num_levels: Int
    var levels: [Level] = []

    init(num_levels: Int) {
        self.num_levels = num_levels
    }

    func park_vehicle(vehicle: Vehicle) -> Bool {
        for level in levels {
            if level.park_vehicle(vehicle) {
                return true
            }
        }
        return false
    }
}

class Level {
    let SPOTS_PER_ROW = 10
    var floor: Int
    var num_spots: Int
    var available_spots: Int = 0
    var spots: [ParkingSpot] = []

    init(floor: Int, total_spots: Int) {
        self.floor = floor
        self.num_spots = total_spots
    }

    func spot_freed() {
        available_spots += 1
    }

    func park_vehicle(vehicle: Vehicle) -> ParkingSpot? {
        let spot = _find_available_spot(vehicle)
        if spot == nil {
            return nil
        } else {
            spot!.park_vehicle(vehicle)
            return spot
        }
    }

    func _find_available_spot(vehicle: Vehicle) -> ParkingSpot? {
        // Find an available spot where vehicle can fit, or return nil
        return nil
    }

    func _park_starting_at_spot(spot: ParkingSpot, vehicle: Vehicle) {
        // Occupy starting at spot.spot_number to vehicle.spot_size.
    }
}

class ParkingSpot {
    var level: Level
    var row: Int
    var spot_number: Int
    var spot_size: VehicleSize
    var vehicle_size: VehicleSize
    var vehicle: Vehicle? = nil

    init(level: Level, row: Int, spot_number: Int, spot_size: VehicleSize, vehicle_size: VehicleSize) {
        self.level = level
        self.row = row
        self.spot_number = spot_number
        self.spot_size = spot_size
        self.vehicle_size = vehicle_size
    }

    func is_available() -> Bool {
        return vehicle == nil
    }

    func can_fit_vehicle(vehicle: Vehicle) -> Bool {
        if self.vehicle != nil {
            return false
        }
        return vehicle.can_fit_in_spot(self)
    }

    func park_vehicle(vehicle: Vehicle) {
        // Implement parking logic
    }

    func remove_vehicle(vehicle: Vehicle) {
        // Implement removal logic
    }
}