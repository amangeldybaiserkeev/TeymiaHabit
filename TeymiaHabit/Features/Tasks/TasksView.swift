import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var allTasks: [TodoTask]
    @Query(filter: #Predicate<TaskList> { $0.group == nil }, sort: \TaskList.title)
    private var standaloneLists: [TaskList]
    
    @Query(sort: \TaskGroup.createdAt)
    private var groups: [TaskGroup]
    
    @State private var selectedScope: TaskScope?
    
    var body: some View {
        List {
            // MARK: - Scopes
            Section {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    TaskScopeNavigationButton(title: "Completed", icon: "checkmark.circle.fill", color: Color(#colorLiteral(red: 0.007716967259, green: 0.7099662423, blue: 0.635252893, alpha: 1)), count: 0) {
                        selectedScope = .completed
                    }
                    TaskScopeNavigationButton(title: "Inbox", icon: "tray.fill", color: Color(#colorLiteral(red: 0.2824559212, green: 0.5449249148, blue: 0.9648384452, alpha: 1)), count: inboxCount) {
                        selectedScope = .inbox
                    }
                    TaskScopeNavigationButton(title: "Upcoming", icon: "calendar", color: Color(#colorLiteral(red: 0.9804772735, green: 0.3530035317, blue: 0.3137320876, alpha: 1)), count: upcomingCount) {
                        selectedScope = .upcoming
                    }
                    TaskScopeNavigationButton(title: "Today", icon: "star.fill", color: .mainApp, count: todayCount) {
                        selectedScope = .today
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            // MARK: - My Lists
            if !standaloneLists.isEmpty {
                Section("My Lists") {
                    ForEach(standaloneLists) { list in
                        TaskListNavigationRow(
                            title: list.title,
                            icon: list.iconName,
                            color: list.iconColor.color,
                            count: list.tasks.filter { !$0.isCompleted }.count
                        )
                    }
                }
            }
            
            // MARK: - Groups
            ForEach(groups) { group in
                Section(group.title) {
                    ForEach(group.lists.sorted(by: { $0.title < $1.title })) { list in
                        TaskGroupNavigationRow(title: list.title)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Tasks")
        .navigationDestination(item: $selectedScope) { scope in
            switch scope {
            case .inbox: Text("Inbox")
            case .today: Text("Today")
            case .upcoming: Text("Upcoming")
            case .completed: Text("Completed")
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: addList) {
                    Label("Add List", systemImage: "plus")
                }
                Button(action: addTask) {
                    Image(systemName: "plus.circle")
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var inboxCount: Int {
        allTasks.filter { !$0.isCompleted && ($0.list == nil || $0.list?.title == "Inbox") }.count
    }
    
    private var todayCount: Int {
        let calendar = Calendar.current
        return allTasks.filter { task in
            guard let date = task.dueDate, !task.isCompleted else { return false }
            return calendar.isDateInToday(date)
        }.count
    }
    
    private var upcomingCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return allTasks.filter { task in
            guard let date = task.dueDate, !task.isCompleted else { return false }
            return date > calendar.date(byAdding: .day, value: 1, to: today) ?? today
        }.count
    }
    
    private func addTask() { }
    private func addList() { }
}

struct TaskListNavigationRow: View {
    let title: String
    let icon: String
    let color: Color
    let count: Int
    
    var body: some View {
        NavigationLink(destination: Text("Список \(title)")) {
            HStack {
                Label(
                    title: { Text(title)
                            .fontWeight(.semibold)
                    },
                    icon: { Image(systemName: icon)
                            .foregroundStyle(color.gradient)
                    }
                )
                Spacer()
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
            }
        }
        .navigationLinkIndicatorVisibility(.hidden)
    }
}

struct TaskGroupNavigationRow: View {
    let title: String
    
    var body: some View {
        NavigationLink(destination: Text("Список \(title)")) {
            HStack {
                Label(
                    title: { Text(title)
                            .fontWeight(.bold)
                    },
                    icon: { Image(systemName: "square.stack.3d.up")
                            .foregroundStyle(Color.primary)
                    }
                )
            }
        }
        .navigationLinkIndicatorVisibility(.hidden)
    }
}

struct TaskScopeNavigationButton: View {
    let title: String
    let icon: String
    let color: Color
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(color.gradient)
                    Spacer()
                    Text("\(count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary.gradient)
                }
                
                Text(title)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary.gradient)
            }
            .contentShape(Rectangle())
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
    }
}
