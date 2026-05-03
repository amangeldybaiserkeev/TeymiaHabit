// MARK: - Premium Features
extension StoreKitService {
    var maxHabitsCount: Int {
        isPremium ? .max : 3
    }

    var maxRemindersCount: Int {
        isPremium ? 10 : 2
    }
}
