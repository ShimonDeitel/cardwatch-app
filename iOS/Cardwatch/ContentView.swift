import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAdd = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingItem: CardEntry?

    @State private var newCardName: String = ""
    @State private var newBalance: String = ""
    @State private var newDueDate: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if store.items.isEmpty {
                    ContentUnavailableView(
                        "No entries yet",
                        systemImage: "leaf",
                        description: Text("Tap + to add your first entry.")
                    )
                } else {
                    List {
                        ForEach(store.items) { item in
                            Button {
                                editingItem = item
                                loadEdit(item)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.cardName)
                                        .font(Theme.headlineFont)
                                        .foregroundStyle(.primary)
                                    Text(item.balance + " · " + item.dueDate)
                                        .font(Theme.captionFont)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .accessibilityIdentifier("itemRow_\(item.id.uuidString)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Cardwatch")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAdd = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAdd) {
                addSheet
            }
            .sheet(item: $editingItem) { item in
                editSheet(for: item)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var addSheet: some View {
        NavigationStack {
            Form {
                TextField("CardName", text: $newCardName)
                    .accessibilityIdentifier("addCardNameField")
                TextField("Balance", text: $newBalance)
                    .accessibilityIdentifier("addBalanceField")
                TextField("DueDate", text: $newDueDate)
                    .accessibilityIdentifier("addDueDateField")
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle("Add Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAdd = false
                    }
                    .accessibilityIdentifier("addCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = CardEntry(cardName: newCardName, balance: newBalance, dueDate: newDueDate)
                        store.add(item)
                        resetNew()
                        showAdd = false
                    }
                    .accessibilityIdentifier("addSaveButton")
                    .disabled(newCardName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func editSheet(for item: CardEntry) -> some View {
        NavigationStack {
            Form {
                TextField("CardName", text: $editCardName)
                    .accessibilityIdentifier("editCardNameField")
                TextField("Balance", text: $editBalance)
                    .accessibilityIdentifier("editBalanceField")
                TextField("DueDate", text: $editDueDate)
                    .accessibilityIdentifier("editDueDateField")
                Button("Delete Entry", role: .destructive) {
                    store.delete(item)
                    editingItem = nil
                }
                .accessibilityIdentifier("editDeleteButton")
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        editingItem = nil
                    }
                    .accessibilityIdentifier("editCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = item
        updated.cardName = editCardName
        updated.balance = editBalance
        updated.dueDate = editDueDate
                        store.update(updated)
                        editingItem = nil
                    }
                    .accessibilityIdentifier("editSaveButton")
                }
            }
        }
    }

    private func resetNew() {
        newCardName = ""
        newBalance = ""
        newDueDate = ""
    }

    private func loadEdit(_ item: CardEntry) {
        editCardName = item.cardName
        editBalance = item.balance
        editDueDate = item.dueDate
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
