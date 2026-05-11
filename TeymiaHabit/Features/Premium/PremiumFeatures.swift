// MARK: - Premium Features
extension StoreKitService {

    var maxHabitsCount: Int {
        isPremium ? .max : 3
    }

    var maxRemindersCount: Int {
        isPremium ? 10 : 2
    }

    func canUseSounds<T: HabitSoundProtocol>(_ sound: T) -> Bool {
        sound.isFree || isPremium
    }

    func canUseIcon(_ icon: AppIcon) -> Bool {
        icon.isFree || isPremium
    }
}
