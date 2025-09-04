//
//  ContentView.swift
//  FlashCards
//
//  Created by Julian Richter on 7/12/25.
//

import SwiftUI
import SwiftData

#if DEBUG
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        DetailView(item: item)
                    } label: {
                        CardItemView(item: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .background(ColorPalette.floralWhite)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .tint(ColorPalette.flame)
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                            .labelStyle(.iconOnly)
                            .foregroundColor(ColorPalette.flame)
                    }
                }
            }
        } detail: {
            Text("Select an item")
                .font(.title2)
                .foregroundColor(ColorPalette.blackOlive)
                .padding()
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

struct CardItemView: View {
    let item: Item
    
    var body: some View {
        HStack {
            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                .foregroundColor(ColorPalette.blackOlive)
                .font(.body)
            Spacer()
        }
        .padding()
        .background(ColorPalette.timberwolf)
        .cornerRadius(12)
        .shadow(color: ColorPalette.eerieBlack.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct DetailView: View {
    let item: Item
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Flashcard Details")
                .font(.largeTitle)
                .foregroundColor(ColorPalette.blackOlive)
                .padding(.top)
            
            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                .font(.title2)
                .foregroundColor(ColorPalette.blackOlive)
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: ColorPalette.gradientTop,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

#endif
