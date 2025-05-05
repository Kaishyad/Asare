import SwiftUI
import AVFoundation

struct IdentifiableImage: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage
}

struct CookModeView: View {
    @EnvironmentObject var settings: AppSettings
    
    let recipeId: Int64
    @State private var instructions: [(stepNumber: Int, instructionText: String)] = []
    @State private var currentStep: Int = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var isSheetPresented = false
    @State private var isIngredientsSheetPresented = false
    @State private var ingredients: [String: [(name: String, amount: String, measurement: String)]] = [:]
    
    @State private var coverImagePath: String?
    @State private var otherImagePaths: [String] = []
    @State private var selectedImage: IdentifiableImage?
    
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var isSpeaking = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Cook Mode")
                    .font(settings.largeTitleFont)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .padding(.top)
                    .accessibilityAddTraits(.isHeader)

               // Spacer()
                Button(action: { isSheetPresented.toggle() }) {
                    Image(systemName: "book.fill")
                        .font(.title)
                        .foregroundColor(.pink)
                        .padding(.top)

                }.accessibilityAddTraits(.isButton)
                Button(action: { isIngredientsSheetPresented.toggle() }) {
                    Image(systemName: "carrot")
                        .font(.title)
                        .foregroundColor(.pink)
                        .padding(.top)
                }
                .accessibilityAddTraits(.isButton)
            }
            .padding()
            
            //MARK: - Step Instructions
            TabView(selection: $currentStep) {
                ForEach(instructions.indices, id: \.self) { index in
                    VStack {
                        HStack {
                            Text("Step \(instructions[index].stepNumber)")
                                .font(settings.midTitleFont)
                                .foregroundColor(.pink)

                            Button(action: {
                                readCurrentStep()
                            }) {
                                Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.1")
                                    .font(.title)
                                    .foregroundColor(.pink)
                                    .padding(.leading, 8)
                            }
                            .accessibilityLabel("Read instruction aloud")
                            .accessibilityAddTraits(.isButton)
                        }
                        .padding(.bottom, 10)

                        instructionTextWithBoldIngredients(instructionText: instructions[index].instructionText)
                            .font(settings.cookfont)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxHeight: .infinity)
                            .frame(maxWidth: .infinity) //fixed dimensions
                            .frame(minHeight: 300)
                            .background(settings.isDarkMode ? Color(uiColor: .secondarySystemBackground) : Color.white )
                            .cornerRadius(20)
                            .shadow(radius: 5)
                            .padding(.horizontal, 20)
                    }
                    .frame(height: 470)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 500)


            Spacer()
            let validImages: [UIImage] = allImagePaths()
                .compactMap { path in
                    guard FileManager.default.fileExists(atPath: path),
                          let image = UIImage(contentsOfFile: path)
                    else {
                        return nil
                    }
                    return image
                }

            if !validImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(validImages.indices, id: \.self) { index in
                            let image = validImages[index]
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(10)
                                .onTapGesture {
                                    selectedImage = IdentifiableImage(image: image)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 8)
            }

            
            Spacer()
            
           
            HStack {
                if currentStep > 0 {
                    Button(action: { withAnimation { currentStep -= 1 } }) {
                        Text("◀ Previous")
                            .font(settings.fontCookNext)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink)
                            .cornerRadius(10)
                    }                            .accessibilityAddTraits(.isButton)

                }
                if currentStep < instructions.count - 1 {
                    Button(action: { withAnimation { currentStep += 1 } }) {
                        Text("Next ▶")
                            .font(settings.fontCookNext)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink)
                            .cornerRadius(10)
                    }                            .accessibilityAddTraits(.isButton)

                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
        .onAppear {
            fetchInstructions()
            fetchIngredients()
            fetchImages()
        }
        .onDisappear {
            speechSynthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
        }
        .sheet(isPresented: $isSheetPresented) {
            AllInstructionsSheet(instructions: instructions) {
                isSheetPresented = false
            }
        }
        .sheet(isPresented: $isIngredientsSheetPresented) {
            IngredientsSheet(ingredients: ingredients) {
                isIngredientsSheetPresented = false
            }
        }
        .fullScreenCover(item: $selectedImage) { item in
            ZStack {
                BlurView()
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Image(uiImage: item.image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    Spacer()
                    Button("Close") {
                        selectedImage = nil
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                }
            }
        }
    }
    
    //Code Adapted from Agarwal, 2024
    private func readCurrentStep() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        let instruction = instructions[currentStep].instructionText
        let utterance = AVSpeechUtterance(string: instruction)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
       // utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-GB_compact")
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
        isSpeaking = true
    }
    //End Adpation

    private func fetchInstructions() {
        self.instructions = InstructionsManager.shared.fetchInstructions(recipeId: recipeId)
    }
    
    private func fetchIngredients() {
        self.ingredients = IngredientManager.shared.fetchIngredientsGroupedBySection(recipeId: recipeId)
    }
    
    private func fetchImages() {
        self.coverImagePath = RecipeDatabaseManager.shared.getCoverImage(forRecipeId: recipeId)
        self.otherImagePaths = RecipeDatabaseManager.shared.getOtherImages(forRecipeId: recipeId)
    }
    
    private func allImagePaths() -> [String] {
        ([coverImagePath] + otherImagePaths)
            .compactMap { $0 }
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
    
    private func loadImage(fromPath path: String) -> UIImage? {
        if FileManager.default.fileExists(atPath: path) {
            return UIImage(contentsOfFile: path)
        } else {
            return nil
        }
    }
    
    private func getAllIngredients() -> [String] {
        ingredients.values.flatMap { $0.map { $0.name } }
    }
    
    private func instructionTextWithBoldIngredients(instructionText: String) -> Text {
        var modifiedText = Text("")
        var currentText = instructionText
        let allIngredients = getAllIngredients()
        
        var isModified = false
        
        for ingredient in allIngredients {
            if let range = currentText.range(of: ingredient, options: .caseInsensitive) {
                let before = String(currentText[..<range.lowerBound])
                let boldIngredient = Text(String(currentText[range])).bold()
                let after = String(currentText[range.upperBound...])
                modifiedText = modifiedText + Text(before) + boldIngredient
                currentText = after
                isModified = true
            }
        }
        
        return isModified ? (modifiedText + Text(currentText)) : Text(instructionText)
    }
    
    
    
    struct Ingredient: Hashable {
        let name: String
        let amount: String
        let measurement: String
    }

    //Code for strike through adapted from Hamdouchi, 2023
    struct IngredientsSheet: View {
        @EnvironmentObject var settings: AppSettings

        let ingredients: [String: [(name: String, amount: String, measurement: String)]]
        let onDismiss: () -> Void
        
        @State private var completedIngredients: Set<String> = []
        private let completedIngredientsKey = "completedIngredients"
        
        var body: some View {
            NavigationView {
                List {
                    ForEach(ingredients.keys.sorted(), id: \.self) { section in
                        Section(header: Text(section).font(settings.headlineFont).foregroundColor(.pink)) {
                            ForEach(ingredients[section]!, id: \.name) { ingredient in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(ingredient.name)
                                            .font(settings.font)
                                            .strikethrough(completedIngredients.contains(ingredient.name), color: .black)
                                        
                                        Spacer()
                                        
                                        Text("\(ingredient.amount) \(ingredient.measurement)")
                                            .font(settings.subheadlineFont)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        toggleIngredientCompletion(ingredient.name)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("Ingredients", displayMode: .inline)
                .navigationBarItems(trailing: Button("Done") { onDismiss() })
            }
            .onAppear {
                loadCompletedIngredients()
            }
            .onDisappear {
                saveCompletedIngredients()
            }
        }
        
        //Load completed ingredients from UserDefaults
        private func loadCompletedIngredients() {
            if let savedData = UserDefaults.standard.object(forKey: completedIngredientsKey) as? Data {
                if let decodedIngredients = try? JSONDecoder().decode(Set<String>.self, from: savedData) {
                    completedIngredients = decodedIngredients
                }
            }
        }
        
        private func saveCompletedIngredients() {
            if let encoded = try? JSONEncoder().encode(completedIngredients) {
                UserDefaults.standard.set(encoded, forKey: completedIngredientsKey)
            }
        }
        
        private func toggleIngredientCompletion(_ ingredientName: String) {
            if completedIngredients.contains(ingredientName) {
                completedIngredients.remove(ingredientName)
            } else {
                completedIngredients.insert(ingredientName)
            }
        }
    }
    
    
    
    
    struct AllInstructionsSheet: View {
        @EnvironmentObject var settings: AppSettings

        let instructions: [(stepNumber: Int, instructionText: String)]
        let onDismiss: () -> Void
        
        @State private var completedSteps: Set<Int> = []
        
        private let completedStepsKey = "completedSteps"
        
        var body: some View {
            NavigationView {
                List(instructions, id: \.stepNumber) { instruction in
                    VStack(alignment: .leading) {
                        Text("Step \(instruction.stepNumber)")
                            .font(settings.headlineFont)
                            .foregroundColor(.pink)
                        
                        Text(instruction.instructionText)
                            .font(settings.font)
                            .strikethrough(completedSteps.contains(instruction.stepNumber), color: .black)
                            .onTapGesture {
                                toggleStepCompletion(instruction.stepNumber)
                            }
                    }
                    .padding()
                }
                .navigationBarTitle("All Instructions", displayMode: .inline)
                .navigationBarItems(trailing: Button("Done") { onDismiss() })
            }
            .onAppear {
                loadCompletedSteps()
            }
            .onDisappear {
                saveCompletedSteps()
            }
        }
        
        private func loadCompletedSteps() {
            if let savedData = UserDefaults.standard.object(forKey: completedStepsKey) as? Data {
                if let decodedSteps = try? JSONDecoder().decode(Set<Int>.self, from: savedData) {
                    completedSteps = decodedSteps
                }
            }
        }
        
        private func saveCompletedSteps() {
            if let encoded = try? JSONEncoder().encode(completedSteps) {
                UserDefaults.standard.set(encoded, forKey: completedStepsKey)
            }
        }
        
        private func toggleStepCompletion(_ stepNumber: Int) {
            if completedSteps.contains(stepNumber) {
                completedSteps.remove(stepNumber)
            } else {
                completedSteps.insert(stepNumber)
            }
        }
    }
    
    
}
//End adaption


struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        return UIVisualEffectView(effect: blurEffect)
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
