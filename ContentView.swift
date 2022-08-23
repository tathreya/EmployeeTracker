// first screen: display of list of employees (list view), button to add a new employee which takes you to 2nd screen
// second screen: place to enter credentials and save, which would take you back to first screen and update it. Cancel button to go back to first screen too

import SwiftUI
import Firebase
import FirebaseStorage

struct Employee: Identifiable {
    
    var id: String?
    var firstName: String
    var lastName: String
    var emailID: String
    var education: String
    // combo drop down box
    var department: String
    var address: String
    var salary: String
    var photoID: String
    
}

struct ListFrame: View {
    
    @State var employees = [Employee]()
    @State var retrievedImages = [UIImage]()
    
    @State var image: UIImage = UIImage()
    
    func getData() async {
        
        retrievedImages.removeAll()
        
        // get reference to data base
        let db = Firestore.firestore()
        
        var imagesTemp = [UIImage]()

        // read in the employees from employeelist data base
        await db.collection("EmployeeList").getDocuments {  snapshot, error in

            // checking for errros
            if error == nil {

                // no errors

                if let snapshot = snapshot {

                    // get all documents and create employees

                    self.employees = snapshot.documents.map { document in

                    var new_employee:Employee = Employee(firstName: document["firstName"] as? String ?? "", lastName:  document["lastName"] as? String ?? "" , emailID:  document["emailID"] as? String ?? "", education:  document["education"] as? String ?? "", department: document["department"] as? String ?? "", address: document["address"] as? String ?? "", salary:  document["salary"] as? String ?? "", photoID: document["photoID"] as? String ?? "")
                        
                    new_employee.id = document.documentID
                        

                    let storageRef = Storage.storage().reference()
                    let fileRef = storageRef.child("profile_pictures/\(new_employee.photoID).jpg")
                        
                        fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in

                        if let error = error {

                        }
                        else {
                        
                            image = UIImage(data: data!)!
                            imagesTemp.append(image)
                            print("here are images ")
                            print(imagesTemp)
                            self.retrievedImages = imagesTemp

                        }
                    }
            

                    return new_employee

                    }
                    

                }

            }
            else {

                // handle error

                print("error")

            }
        }
    }
    
    func deleteData(at indexSet: IndexSet) {
        
        let db = Firestore.firestore()
        
        let storageRef = Storage.storage().reference()
        
        indexSet.forEach { index in
            
            let employee = employees[index]
            let photoId = employee.photoID
            let fileRef = storageRef.child("profile_pictures/\(employee.photoID).jpg")
            fileRef.delete { error in
                
                if let error = error {
                    
                    // error occured
                }
                else {
                    
                }
            }
            
            db.collection("EmployeeList").document(employee.id!).delete()
            employees.remove(atOffsets: indexSet)
        }
        
    }
    
//    func getPhoto(employee: Employee) async -> UIImage {
//
//        return nil
//
//    }
    
    var body: some View {
        
        
        NavigationView {

            VStack {
            
                Spacer()
                
                List {

                    ForEach(employees) { employee in

                        let firstName = employee.firstName
                        let lastName = employee.lastName
                        let text = firstName + " " + lastName

                        HStack {

                            Text(text)
                            //Image(uiImage: image).resizable()
//                                                        .frame(width: 50, height: 50)
//                                                        .foregroundColor(.white)
//                                                        .clipShape(Circle())
                        }
//                        .task {
//                            image = await getPhoto(employee: employee)
//                        }
                    }.onDelete(perform: deleteData)

//                    ForEach(retrievedImages, id: \.self) { image in
//
//                        Image(uiImage: image).resizable()
//                            .frame(width: 50, height: 50)
//                            .foregroundColor(.white)
//                            .clipShape(Circle())
//                    }

                }
                .navigationBarTitle("List of Employees")
                .task {
                    await getData()
                }
                
                Spacer()
                
                HStack {
                   
                    Button(action: {
                     }) {
                         NavigationLink(destination: AddEmployeeFrame(employees: $employees, retrievedImages: $retrievedImages)) {
                             Text("Add Employee")
                         }
                     }
                    
                }
            }
        
            

        }
    }
}

struct AddEmployeeFrame: View {

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var emailID: String = ""
    @State private var education: String = ""
    // combo drop down box
    @State private var department: String = ""
    @State private var address: String = ""
    @State private var salaryString: String = ""
    @State private var profilePic: UIImage?
    
    @State private var showingAlert = false
    
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    
    @State var image: UIImage = UIImage()
    
    @Binding var employees: [Employee]
    @Binding var retrievedImages: [UIImage]
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    func addData(firstName: String, lastName: String, emailID: String, education: String, department: String, address: String, salary: String, photoID: String) {
        
        // get reference to database
        let db = Firestore.firestore()
        
        // add a document to collection
        
        db.collection("EmployeeList").addDocument(data: ["firstName": firstName, "lastName": lastName, "emailID": emailID,
                                                         "education": education, "department": department, "address": address,
                                                         "salary": salary, "photoID": photoID]) { error in
            
            if error == nil {
                
               
            }
            else {
                
                // handle error
            }
            
        }
        
        
    }
    
    func uploadPhoto(employee: Employee) {
        
        guard selectedImage != nil else {
            return
        }
        // create storage reference
        
        let storageRef = Storage.storage().reference()
        
        // turn our image into data
        
        let imageData = selectedImage!.jpegData(compressionQuality: 0.8)
        
        guard imageData != nil else {
            return
        }
        
        // specify file path
         
        let path = "profile_pictures/\(employee.photoID).jpg"
        let fileRef = storageRef.child(path)
        
        // upload that data
        
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in
            
            if error == nil && metadata != nil {
                
                // save a reference to file in firestore db
                
            }
        }
        
       
    }
    
    var body: some View {
        
        NavigationView {
            
            // text fields
            VStack(alignment: .center, spacing: 25) {
            
                Group {
              
                    TextField("First Name", text: $firstName).multilineTextAlignment(.center)
               
                    TextField("Last Name", text: $lastName).multilineTextAlignment(.center)
               
                    TextField("Email ID", text: $emailID).multilineTextAlignment(.center)
              
                    TextField("Education", text: $education).multilineTextAlignment(.center)
                }
            
                Menu("Select Department") {

                
                    Button("Other") {
                        department = "Other"
                        print(department)
                    }
                
                    Button("IT Department") {
                        department = "IT Department"
                        print(department)
                    }
                    Button("Storage Department") {
                        department = "Storage Department"
                        print(department)
                    }
                    Button("HR Department") {
                        department = "HR Department"
                        print(department)
                    }
                    Button("Testing Department") {
                        department = "Testing Department"
                        print(department)
                    }
                }

                TextField("Address", text: $address).multilineTextAlignment(.center)
                TextField("Salary", text: $salaryString).multilineTextAlignment(.center)
                
                Spacer()
                
                if selectedImage != nil {
                    Image(uiImage: selectedImage!).resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                    
                }
                
                Button {
                    
                    // show the image picker
                    isPickerShowing = true
                } label: {
                    Text("Select a Profile Photo")
                }
        
                // cancel and save buttons
                HStack() {
                
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        
                        if (firstName == "" || lastName == "" || emailID == "" || education == "" || department == "" || address == "" || salaryString == "" || selectedImage == nil) {
                            
                            showingAlert = true
                            
                        }
                        else {

                            // upload Photo to storage
                            
                            let photoID = UUID().uuidString
                            
                            let new_employee = Employee(firstName: firstName, lastName: lastName, emailID: emailID, education: education, department: department, address: address, salary: salaryString, photoID: photoID)
                            
                            // adding data to server
                            self.addData(firstName: new_employee.firstName, lastName: new_employee.lastName, emailID: new_employee.emailID, education: new_employee.education, department: new_employee.department, address: new_employee.address, salary: new_employee.salary, photoID: new_employee.photoID)
                            
                            self.uploadPhoto(employee: new_employee)
                            
                            let storageRef = Storage.storage().reference()
                            
                            let fileRef = storageRef.child("profile_pictures/\(new_employee.photoID).jpg")
                                
                                fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in

                                if let error = error {

                                }
                                else {
                                
                                    image = UIImage(data: data!)!
                                    self.retrievedImages.append(image)

                                }
                            }

                            employees.append(new_employee)
                            retrievedImages.append(image)
                        
                            presentationMode.wrappedValue.dismiss()
                        }
                        
                    }, label: {
                        Text("Save")
                    }).alert(isPresented: $showingAlert) {
                        
                        Alert(title: Text("Error"), message: Text("Make sure all text fields are filled and you upload a profile picture!"), dismissButton: .default(Text("OK")))

                    }
                                      
                    Spacer()
                    

                }
            }.sheet(isPresented: $isPickerShowing , onDismiss: nil) {
                
                // image picker
                ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
                
            }
                   
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {

        ListFrame()
        
    }
}
