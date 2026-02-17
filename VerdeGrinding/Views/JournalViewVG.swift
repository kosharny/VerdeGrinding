import SwiftUI
import PhotosUI

struct JournalViewVG: View {
    @EnvironmentObject var viewModel: ViewModelVG
    @State private var showEntrySheet = false
    
    var body: some View {
        ZStack {
            viewModel.themeGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderBarVG(title: "Field Notes", showBackButton: false)
                
                // Main Content
                ZStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            // Recent Entries
                            HStack {
                                Text("Recent Observations")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            LazyVStack(spacing: 15) {
                                ForEach(viewModel.sortedJournalEntries) { entry in
                                    JournalEntryCard(entry: entry)
                                }
                                if viewModel.journalEntries.isEmpty {
                                    VStack(spacing: 10) {
                                        Image(systemName: "book.closed")
                                            .font(.largeTitle)
                                            .foregroundColor(.gray)
                                        Text("No entries yet. Start tracking your progress!")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.top, 50)
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer(minLength: 120) // Ensure enough space at bottom for FAB
                        }
                    }
                    
                    // FAB
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            // Hint Text
                            if viewModel.journalEntries.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    
                                    Text("Share your daily observations & insights here")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.trailing, 8)
                                .padding(.bottom, 30)
                            }
                            Spacer()
                            
                            Button(action: { showEntrySheet = true }) {
                                Circle()
                                    .fill(Color.neonLeaf)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: .neonLeaf.opacity(0.5), radius: 10)
                                    .overlay(
                                        Image(systemName: "plus")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                    )
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showEntrySheet) {
             NewEntrySheet(isPresented: $showEntrySheet) { title, text, date, mood, tags, imageData in
                 let newEntry = JournalEntryVG(
                     title: title,
                     date: date,
                     text: text,
                     mood: mood,
                     photoPath: nil,
                     tags: tags
                 )
                 viewModel.addJournalEntry(newEntry, imageData: imageData)
             }
        }
    }
}

struct JournalEntryCard: View {
    @EnvironmentObject var viewModel: ViewModelVG
    let entry: JournalEntryVG
    
    var body: some View {
        BlurCardVG {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(entry.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    // Mood Icon (Placeholder)
                    Image(systemName: "face.smiling")
                        .foregroundColor(.neonLeaf)
                }
                
                if !entry.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(entry.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color.white.opacity(0.1))
                                    .foregroundColor(.neonLeaf)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                if let photoPath = entry.photoPath, let image = viewModel.loadImageFromDocuments(fileName: photoPath) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.vertical, 5)
                }
                
                Text(entry.text)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(3)
            }
        }
    }
}

struct NewEntrySheet: View {
    @Binding var isPresented: Bool
    var onSave: (String, String, Date, String, [String], Data?) -> Void
    
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var date: Date = Date()
    @State private var mood: String = "Neutral"
    @State private var selectedTags: Set<String> = []
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    let availableTags = [
        ("Water", "drop.fill", Color.cyan),
        ("Prune", "scissors", Color.orange),
        ("Fertilize", "bolt.fill", Color.yellow),
        ("Repot", "arrow.up.circle.fill", Color.green),
        ("Mist", "cloud.drizzle.fill", Color.blue),
        ("Clean", "sparkles", Color.white)
    ]
    
    var body: some View {
        NavigationView {
             ZStack {
                 Color.darkForest.ignoresSafeArea()
                 
                 ScrollView {
                     VStack(spacing: 20) {
                         TextField("", text: $title, prompt: Text("Title").foregroundColor(.gray))
                             .font(.title2)
                             .foregroundColor(.white)
                             .padding()
                             .background(Color.white.opacity(0.1))
                             .cornerRadius(10)
                             .padding(.horizontal)
                         
                         DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                             .foregroundColor(.white)
                             .padding(.horizontal)
                             .colorScheme(.dark)
                         
                         // Actions Grid
                         VStack(alignment: .leading) {
                             Text("Actions Taken")
                                 .font(.caption)
                                 .foregroundColor(.gray)
                                 .padding(.horizontal)
                             
                             LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 15) {
                                 ForEach(availableTags, id: \.0) { tag in
                                     Button(action: {
                                         if selectedTags.contains(tag.0) {
                                             selectedTags.remove(tag.0)
                                         } else {
                                             selectedTags.insert(tag.0)
                                         }
                                     }) {
                                         VStack {
                                             Image(systemName: tag.1)
                                                 .font(.title2)
                                             Text(tag.0)
                                                 .font(.caption)
                                         }
                                         .frame(width: 80, height: 80)
                                         .background(selectedTags.contains(tag.0) ? tag.2.opacity(0.3) : Color.white.opacity(0.05))
                                         .foregroundColor(selectedTags.contains(tag.0) ? tag.2 : .gray)
                                         .cornerRadius(15)
                                         .overlay(
                                             RoundedRectangle(cornerRadius: 15)
                                                 .stroke(selectedTags.contains(tag.0) ? tag.2 : Color.clear, lineWidth: 2)
                                         )
                                     }
                                 }
                             }
                             .padding(.horizontal)
                         }
                         
                         TextEditor(text: $text)
                             .frame(minHeight: 150)
                             .scrollContentBackground(.hidden)
                             .background(Color.white.opacity(0.1))
                             .foregroundColor(.white)
                             .cornerRadius(10)
                             .padding(.horizontal)
                             .overlay(
                                Group {
                                    if text.isEmpty {
                                        Text("Write your observation...")
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 8)
                                            .allowsHitTesting(false)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    }
                                }
                             )
                         
                             .padding(.horizontal)
                         
                         // Image Picker
                         VStack(alignment: .leading) {
                             Text("Observation Photo")
                                 .font(.caption)
                                 .foregroundColor(.gray)
                                 .padding(.horizontal)
                             
                             PhotosPicker(selection: $selectedItem, matching: .images) {
                                 if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                     Image(uiImage: uiImage)
                                         .resizable()
                                         .scaledToFill()
                                         .frame(height: 150)
                                         .frame(maxWidth: .infinity)
                                         .cornerRadius(12)
                                         .padding(.horizontal)
                                 } else {
                                     VStack {
                                         Image(systemName: "camera.fill")
                                             .font(.title2)
                                         Text("Add Photo")
                                              .font(.caption)
                                     }
                                     .frame(height: 100)
                                     .frame(maxWidth: .infinity)
                                     .background(Color.white.opacity(0.1))
                                     .foregroundColor(.gray)
                                     .cornerRadius(12)
                                     .padding(.horizontal)
                                 }
                             }
                             .onChange(of: selectedItem) { newItem in
                                 Task {
                                     if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                         selectedImageData = data
                                     }
                                 }
                             }
                         }
                         
                         Button(action: {
                             onSave(title, text, date, mood, Array(selectedTags), selectedImageData)
                             isPresented = false
                         }) {
                             Text("Save Entry")
                                 .frame(maxWidth: .infinity)
                                 .padding(.vertical, 8)
                         }
                         .buttonStyle(.borderedProminent)
                         .tint(.neonLeaf)
                         .disabled(title.isEmpty)
                         .padding(.top, 10)
                         .padding(.horizontal)
                         
                         Spacer()
                     }
                     .padding(.top)
                 }
                 .onTapGesture {
                     hideKeyboard()
                 }
             }
             .navigationTitle("New Entry")
             .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                 ToolbarItem(placement: .cancellationAction) {
                     Button("Cancel") { isPresented = false }
                 }
             }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
