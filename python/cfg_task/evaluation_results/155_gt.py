from abc import ABCMeta, abstractmethod
from enum import Enum
class VehicleSize(Enum):
    MOTORCYCLE = 0
    COMPACT = 1
    LARGE = 2
MOTORCYCLE = 0
COMPACT = 1
LARGE = 2
class Vehicle(metaclass=ABCMeta):

    def __init__(self, vehicle_size, license_plate, spot_size):
        self.vehicle_size = vehicle_size
        self.license_plate = license_plate
        self.spot_size
        self.spots_taken = []

    def clear_spots(self):
        for spot in self.spots_taken:
            spot.remove_vehicle(self)
        self.spots_taken = []

    def take_spot(self, spot):
        self.spots_taken.append(spot)

    @abstractmethod
    def can_fit_in_spot(self, spot):
        pass
def __init__(self, vehicle_size, license_plate, spot_size):
    self.vehicle_size = vehicle_size
    self.license_plate = license_plate
    self.spot_size
    self.spots_taken = []
self.vehicle_size = vehicle_size
self.license_plate = license_plate
self.spot_size
self.spots_taken = []
def clear_spots(self):
    for spot in self.spots_taken:
        spot.remove_vehicle(self)
    self.spots_taken = []
spot
self.spots_taken
spot.remove_vehicle(self)
self.spots_taken = []
def take_spot(self, spot):
    self.spots_taken.append(spot)
self.spots_taken.append(spot)
@abstractmethod
def can_fit_in_spot(self, spot):
    pass
pass
class Motorcycle(Vehicle):

    def __init__(self, license_plate):
        super(Motorcycle, self).__init__(VehicleSize.MOTORCYCLE, license_plate, spot_size=1)

    def can_fit_in_spot(self, spot):
        return True
def __init__(self, license_plate):
    super(Motorcycle, self).__init__(VehicleSize.MOTORCYCLE, license_plate, spot_size=1)
super(Motorcycle, self).__init__(VehicleSize.MOTORCYCLE, license_plate)
def can_fit_in_spot(self, spot):
    return True
return True
class Car(Vehicle):

    def __init__(self, license_plate):
        super(Car, self).__init__(VehicleSize.COMPACT, license_plate, spot_size=1)

    def can_fit_in_spot(self, spot):
        return spot.size in (VehicleSize.LARGE, VehicleSize.COMPACT)
def __init__(self, license_plate):
    super(Car, self).__init__(VehicleSize.COMPACT, license_plate, spot_size=1)
super(Car, self).__init__(VehicleSize.COMPACT, license_plate)
def can_fit_in_spot(self, spot):
    return spot.size in (VehicleSize.LARGE, VehicleSize.COMPACT)
return spot.size in (VehicleSize.LARGE, VehicleSize.COMPACT)
class Bus(Vehicle):

    def __init__(self, license_plate):
        super(Bus, self).__init__(VehicleSize.LARGE, license_plate, spot_size=5)

    def can_fit_in_spot(self, spot):
        return spot.size == VehicleSize.LARGE
def __init__(self, license_plate):
    super(Bus, self).__init__(VehicleSize.LARGE, license_plate, spot_size=5)
super(Bus, self).__init__(VehicleSize.LARGE, license_plate)
def can_fit_in_spot(self, spot):
    return spot.size == VehicleSize.LARGE
return spot.size == VehicleSize.LARGE
class ParkingLot(object):

    def __init__(self, num_levels):
        self.num_levels = num_levels
        self.levels = []

    def park_vehicle(self, vehicle):
        for level in self.levels:
            if level.park_vehicle(vehicle):
                return True
        return False
def __init__(self, num_levels):
    self.num_levels = num_levels
    self.levels = []
self.num_levels = num_levels
self.levels = []
def park_vehicle(self, vehicle):
    for level in self.levels:
        if level.park_vehicle(vehicle):
            return True
    return False
level
self.levels
level.park_vehicle(vehicle)
return False
return True
class Level(object):
    SPOTS_PER_ROW = 10

    def __init__(self, floor, total_spots):
        self.floor = floor
        self.num_spots = total_spots
        self.available_spots = 0
        self.spots = []

    def spot_freed(self):
        self.available_spots += 1

    def park_vehicle(self, vehicle):
        spot = self._find_available_spot(vehicle)
        if spot is None:
            return None
        else:
            spot.park_vehicle(vehicle)
            return spot

    def _find_available_spot(self, vehicle):
        """Find an available spot where vehicle can fit, or return None"""
        pass

    def _park_starting_at_spot(self, spot, vehicle):
        """Occupy starting at spot.spot_number to vehicle.spot_size."""
        pass
SPOTS_PER_ROW = 10
def __init__(self, floor, total_spots):
    self.floor = floor
    self.num_spots = total_spots
    self.available_spots = 0
    self.spots = []
self.floor = floor
self.num_spots = total_spots
self.available_spots = 0
self.spots = []
def spot_freed(self):
    self.available_spots += 1
self.available_spots += 1
def park_vehicle(self, vehicle):
    spot = self._find_available_spot(vehicle)
    if spot is None:
        return None
    else:
        spot.park_vehicle(vehicle)
        return spot
spot = self._find_available_spot(vehicle)
spot Is None
return None
spot.park_vehicle(vehicle)
return spot
def _find_available_spot(self, vehicle):
    """Find an available spot where vehicle can fit, or return None"""
    pass
'Find an available spot where vehicle can fit, or return None'
pass
def _park_starting_at_spot(self, spot, vehicle):
    """Occupy starting at spot.spot_number to vehicle.spot_size."""
    pass
'Occupy starting at spot.spot_number to vehicle.spot_size.'
pass
class ParkingSpot(object):

    def __init__(self, level, row, spot_number, spot_size, vehicle_size):
        self.level = level
        self.row = row
        self.spot_number = spot_number
        self.spot_size = spot_size
        self.vehicle_size = vehicle_size
        self.vehicle = None

    def is_available(self):
        return True if self.vehicle is None else False

    def can_fit_vehicle(self, vehicle):
        if self.vehicle is not None:
            return False
        return vehicle.can_fit_in_spot(self)

    def park_vehicle(self, vehicle):
        pass

    def remove_vehicle(self):
        pass
def __init__(self, level, row, spot_number, spot_size, vehicle_size):
    self.level = level
    self.row = row
    self.spot_number = spot_number
    self.spot_size = spot_size
    self.vehicle_size = vehicle_size
    self.vehicle = None
self.level = level
self.row = row
self.spot_number = spot_number
self.spot_size = spot_size
self.vehicle_size = vehicle_size
self.vehicle = None
def is_available(self):
    return True if self.vehicle is None else False
return True if self.vehicle is None else False
def can_fit_vehicle(self, vehicle):
    if self.vehicle is not None:
        return False
    return vehicle.can_fit_in_spot(self)
self.vehicle IsNot None
return False
def park_vehicle(self, vehicle):
    pass
pass
def remove_vehicle(self):
    pass
pass