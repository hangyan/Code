package automobiles

class Vehicle {
  protected def checkEngine() {}
}

class Car extends Vehicle {
  def start() { checkEngine()}
  def tow(car: Car) {
    car.checkEngine()
  }

  def tow(vehicle: Vehicle) {
    vehicle.checkEngine()
  }
}

class GasStation {
  def fillGas(vehicle: Vehicle) {
    vehicle.checkEngine()
  }
}



   
