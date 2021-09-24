import UIKit

// Задача 1

protocol Car {
    var model: String { get }
    var color: CarColor { get }
    var buildDate: Int { get }
    var price: Int { get set }
    var accessories: Set<String> { get set }
    var isServiced: Bool { get set }
}

protocol Dealership {
    var name: String { get }
    var showroomCapacity: Int { get }
    var stockCars: [NewCar] { get set }
    var showroomCars: [NewCar] { get set }
    var cars: [NewCar] { get set }
    
    func offerAccessories(arrayAccessoiries: [String:Int])
    func presaleService(carForService: inout NewCar)
    func addToShowroom(carModel: NewCar)
    func sellCar(carModel: inout NewCar)
    func orderCar(carModel: NewCar)
}

protocol SpecialOffer{
    mutating func addEmergencyPack()
    mutating func makeSpecialOffer() throws
}


enum CarColor: String {
    case wetAsphalt = "Мокрый асфальт"
    case silver = "Серебристый"
    case white = "Белый"
    case purple = "Фиолетовый"
    case green = "Зеленый"
    case lightGreen = "Салатовый"
    case pink = "Розовый"
    case blue = "Синий"
    case lightBlue = "Голубой"
    case gold = "Золотой"
    case beige = "Бежевый"
    case yellow = "Желтый"
    case red = "Красный"
    case black = "Черный"
    var description: String { return self.rawValue}
}

enum SpecialOfferError: Error {
    case theCarIsNotSuitableForTheSpecialOffer
    case theCarIsAlredyInTheShowroom
}

struct NewCar: Car, Equatable {
    var model: String
    var buildDate: Int
    var price: Int
    var color: CarColor
    var accessories: Set<String>
    var isServiced: Bool
}

//MARK: - extension SpecialOffer

extension NewCar: SpecialOffer{
    
    mutating func addEmergencyPack() {
        accessories.insert("Медицинская аптечка")
        accessories.insert("Огнетушитель")
    }
    
    mutating func makeSpecialOffer() throws {
        let currentDate = 2021
        guard buildDate < currentDate else {
            throw SpecialOfferError.theCarIsNotSuitableForTheSpecialOffer
        }
        addEmergencyPack()
        price = price / 100 * 85
        print("Специальное предложение! Скидка 15%! Новая цена \(price)")
    }
}

class NewCentre: Dealership{
    
    var name: String
    var showroomCapacity: Int
    var stockCars: [NewCar]
    var showroomCars: [NewCar]
    var cars: [NewCar] = []
    var tagline: String
    
    init(name: String, showroomCapacity: Int, stockCars: [NewCar], showroomCars: [NewCar], tagline: String){
        self.name = name
        self.showroomCapacity = showroomCapacity
        self.stockCars = stockCars
        self.showroomCars = showroomCars
        self.cars = showroomCars + stockCars
        self.tagline = tagline
    }
    
    func offerAccessories(arrayAccessoiries: [String : Int]) {
        print("Мы предлагаем приобрести следующие аксессуары: \(arrayAccessoiries)")
    }
    
    func presaleService(carForService: inout NewCar) {
        carForService.isServiced = true
        print("""
            Автомобиль: \(carForService.model)
            Цвет: \(carForService.color.description)
            Год выпуска: \(carForService.buildDate)
            Прошел предпродажную подготовку
            """)
    }
    
    func addToShowroom(carModel: NewCar) {
        guard showroomCars.count < showroomCapacity else {
            return print("Шоурум заполнен")
        }
        
        for (index, value) in stockCars.enumerated(){
            if value == carModel{
                stockCars.remove(at: index)
                showroomCars.append(carModel)
                carModel.isServiced
                return print("""
                            Автомобиль: \(carModel.model)
                            Цвет: \(carModel.color.description)
                            Год выпуска: \(carModel.buildDate)
                            Выставлен в шоурум
                            """)
            }
        }
    }
    
    func sellCar(carModel: inout NewCar) {
        guard showroomCars.contains(carModel) else {
            return print("Автомобиля \(carModel.model) нет в шоуруме")
        }
        
        var sellingCar = carModel
        do {
            try sellingCar.makeSpecialOffer()
        } catch {
            print("Автомобиль \(sellingCar.model) не подходит под условия акции. Год выпуска: \(sellingCar.buildDate)")
        }
        
        
        var counterPriceAdditionalAccessories: Int = 0
        let setOfAccessories = Set(accessories.keys)
        let additionalAccessories = setOfAccessories.subtracting(sellingCar.accessories)
        sellingCar.accessories = sellingCar.accessories.intersection(setOfAccessories)
        
        if let index = showroomCars.firstIndex(of: carModel) {
            showroomCars.remove(at: index)
        }
        
        if let index = cars.firstIndex(of: carModel) {
            cars.remove(at: index)
        }
        
        for (key, value) in accessories{
            if additionalAccessories.contains(key) {
                counterPriceAdditionalAccessories += value
            }
        }
        
        print("""
                Автомобиль: \(sellingCar.model)
                Цвет: \(sellingCar.color.description)
                Год выпуска: \(sellingCar.buildDate)
                Реализован по цене: \(sellingCar.price + counterPriceAdditionalAccessories)
                Были проданы дополнительные аксессуары на сумму: \(counterPriceAdditionalAccessories)
                Список аксессуаров: \(additionalAccessories)
                """)
        
        if sellingCar.isServiced{
            print("Проведена предпродажная подготовка")
        } else {
            sellingCar.isServiced = true
            print("Проведена предпродажная подготовка")
        }
    }
    
    func orderCar(carModel: NewCar) {
        cars.append(carModel)
        stockCars.append(carModel)
        print("""
            Автомобиль: \(carModel.model)
            Цвет: \(carModel.color.description)
            Год выпуска: \(carModel.buildDate)
            Добавлен на парковку автосалона
            """)
    }
}

// MARK: extension NewCentre

extension NewCentre {
    
    func makeSpecialOffer() throws {
        let currentDate = 2021
        var listOfferCars: [String] = []
        var listOfferStockCars: [String] = []
        
        for i in cars {
            if i.buildDate < currentDate {
                do {
                    guard stockCars.contains(i) else {
                        throw SpecialOfferError.theCarIsAlredyInTheShowroom
                    }
                    addToShowroom(carModel: i)
                    listOfferStockCars.append(i.model)
                } catch SpecialOfferError.theCarIsAlredyInTheShowroom {
                    listOfferCars.append(i.model)
                    print("\(i.model) уже в шоуруме")
                }
            }
        }
        print("""
                Машины по специальному предложению в шоуруме: \(listOfferCars)
                Машины по специальному предложению на стоянке: \(listOfferStockCars)
                """)
    }
}

var accessories: [String: Int] = ["Медицинская аптечка" : 1850,"Огнетушитель" : 2730, "Буксировочный трос" : 3600, "Знак аварийной остановки" : 800, "Техническая аптечка": 7300, "Видеорегистратор" : 6500, "Навигатор" : 4500,"Тонировка" : 16800,"Пылесос" : 4000, "Освежитель воздуха" : 700,"Адаптер питания" : 1650,"Аудиосистема Bose" : 35000,"Парктроники" : 6800,"GPS маяк" : 1750, "Чехлы" : 9000, "Автомобильные коврики" : 6200,"Спойлеры" : 12000]

var volvoXC90 = NewCar(model: "Volvo XC90", buildDate: 2021, price: 7_500_000, color: CarColor.wetAsphalt, accessories: ["Автомобильные коврики","Аудиосистема Bose"], isServiced: true)
var volvoS60 = NewCar(model: "Volvo S60", buildDate: 2020, price: 4_500_000, color: CarColor.white, accessories: ["Автомобильные коврики", "Парктроники"], isServiced: false)
var lexusNX200 = NewCar(model: "Lexus NX200", buildDate: 2021, price: 3_400_000, color: CarColor.green, accessories: ["Медецинская аптечка","Огнетушитель","Буксировочный трос"], isServiced: false)
var lexus450d = NewCar(model: "Lexus 450d", buildDate: 2020, price: 8_000_000, color: CarColor.black, accessories: [], isServiced: false)
var bmwX5 = NewCar(model: "BMW X5", buildDate: 2021, price: 5_450_000, color: CarColor.gold, accessories: [], isServiced: true)
var bmw3 = NewCar(model: "BMW 3", buildDate: 2020, price: 3_300_000, color: CarColor.lightGreen, accessories: ["Автомобильные коврики"], isServiced: true)
var hondaPilot = NewCar(model: "Honda Pilot", buildDate: 2021, price: 6_700_000, color: CarColor.black, accessories: ["Автомобильные коврики"], isServiced: true)
var hondaCity = NewCar(model: "Honda City", buildDate: 2020, price: 2_400_000, color: CarColor.pink, accessories: ["Автомобильные коврики"], isServiced: true)
var audiQ5 = NewCar(model: "Audi Q5", buildDate: 2021, price: 6_800_000, color: CarColor.silver, accessories: ["Автомобильные коврики"], isServiced: true)
var audiA6 = NewCar(model: "Audi A6", buildDate: 2020, price: 5_300_000, color: CarColor.red, accessories: ["Автомобильные коврики"], isServiced: false)



var volvoDealearcenter = NewCentre(name: "Volvo", showroomCapacity: 5, stockCars: [volvoXC90], showroomCars: [volvoS60], tagline: "Создан с вами")
var lexusDealercenter = NewCentre(name: "Lexus", showroomCapacity: 2, stockCars: [lexus450d, lexusNX200], showroomCars: [lexus450d], tagline: "Неудержимое стремление к совершенству")
var hondaDealercenter = NewCentre(name: "Honda", showroomCapacity: 3, stockCars: [hondaCity, hondaCity], showroomCars: [hondaPilot], tagline: "Сначала человек, потом машина")
var bmwDealercenter = NewCentre(name: "BMW", showroomCapacity: 4, stockCars: [bmw3, bmwX5, bmwX5], showroomCars: [bmwX5, bmw3], tagline: "С удовольствием за рулем")
var audiDealercenter = NewCentre(name: "Audi", showroomCapacity: 5, stockCars: [audiA6, audiA6, audiQ5], showroomCars: [audiQ5, audiA6], tagline: "Продвижение через технологии")

var arrayDealercenters = [volvoDealearcenter, lexusDealercenter, hondaDealercenter, bmwDealercenter, audiDealercenter]

volvoDealearcenter.orderCar(carModel: bmw3)
volvoDealearcenter.orderCar(carModel: bmwX5)
volvoDealearcenter.orderCar(carModel: audiQ5)
volvoDealearcenter.orderCar(carModel: audiA6)
volvoDealearcenter.orderCar(carModel: lexus450d)
volvoDealearcenter.orderCar(carModel: lexusNX200)
volvoDealearcenter.addToShowroom(carModel: bmwX5)
volvoDealearcenter.cars
volvoDealearcenter.showroomCars
volvoDealearcenter.stockCars
volvoDealearcenter.orderCar(carModel: hondaCity)
volvoDealearcenter.addToShowroom(carModel: hondaCity)
try? volvoDealearcenter.makeSpecialOffer()
volvoDealearcenter.addToShowroom(carModel: bmw3)
volvoDealearcenter.cars
volvoDealearcenter.showroomCars
volvoDealearcenter.stockCars


