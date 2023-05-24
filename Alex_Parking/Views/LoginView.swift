//
//  LoginView.swift
//  Alex_Parking
//
//  Created by Alex Olechnowicz on 2023-03-28.
//

import SwiftUI

enum LoginType: String{
    case login = "Log In"
    case signup = "Sign Up"
}

struct LoginView: View {
    
    @State var loginType: LoginType = .login
    
    @State var username = ""
    @State var password = ""
    
    @State var passwordConfirm = ""
    @State var name = ""
    @State var phoneNum = ""
    @State var licensePlate = ""
    
    @State var showAlert = false
    @State var errorTitle = ""
    @State var errorMessage = ""
    
    @State var potentialUser = UserModel()
    
    @State var buttonDisabled = false
    
    @State var signInSuccessful = false
    
    @EnvironmentObject var database: DatabaseConnection
    
    var body: some View {
        NavigationView{
            VStack{
                NavigationLink(destination: ViewParkingView().environmentObject(database), isActive: $signInSuccessful){}
                Form{
                    switch loginType{
                    case .login:
                        //login form
                    
                        Section{
                            TextField("Username", text: $username).keyboardType(.emailAddress)
                            SecureField("Password", text: $password)
                        }
                        
                    case .signup:
                        Section{
                            TextField("Username", text: $username).keyboardType(.emailAddress)
                            SecureField("Password", text: $password)
                            SecureField("Confirm Password", text: $passwordConfirm)
                        }
                    footer:{
                        if password != "" && passwordConfirm != "" && password == passwordConfirm{
                            Text("Passwords match")
                        }
                        else{
                            Text("Passwords must match")
                        }
                    }
                        
                        Section{
                            TextField("Name", text: $name)
                            TextField("Phone Number", text: $phoneNum).keyboardType(.numberPad)
                            TextField("License Plate", text: $licensePlate)
                        }
                    }
                    
                    Section{
                        Picker("", selection: $loginType){
                            Text(LoginType.login.rawValue).tag(LoginType.login)
                            Text(LoginType.signup.rawValue).tag(LoginType.signup)
                        }.pickerStyle(.segmented)
                        
                        
                            Button(action:{
                                
                                buttonDisabled = true
                                
                                potentialUser.email = username
                                potentialUser.password = password
                                
                                if loginType == .signup{
                                    potentialUser.name = name
                                    potentialUser.number = phoneNum
                                    potentialUser.licensePlates.append(licensePlate)
                                }
                                
                                if validated(){
                                    Task{
                                        switch loginType{
                                        case .login:
                                            if await database.logIn(userCredentials: potentialUser){
                                                
                                                signInSuccessful = true
                                                resetFields()
                                                buttonDisabled = false
                                            }
                                            else{
                                                errorTitle = "Could not Log In"
                                                errorMessage = "Incorrect username or password"
                                                showAlert = true
                                                potentialUser = UserModel()
                                                buttonDisabled = false
                                            }
                                        case .signup:
                                            if await database.signUp(newUser: potentialUser){
                                                
                                                
                                                signInSuccessful = true
                                                resetFields()
                                                buttonDisabled = false
                                            }
                                            else{
                                                errorTitle = "Could not Sign Up"
                                                errorMessage = "Username might already be in use"
                                                showAlert = true
                                                potentialUser = UserModel()
                                                buttonDisabled = false
                                            }
                                        }
                                    }
                                }
                                else{
                                    potentialUser = UserModel()
                                    showAlert = true
                                    buttonDisabled = false
                                }
                                
                            }){
                                Text(loginType.rawValue)
                            }.frame(maxWidth: .infinity ,alignment: .center)
                                .disabled(buttonDisabled)
                        
                        
                    }
                    
                    
                }
            }
            .navigationTitle(loginType.rawValue)
                .alert(isPresented: $showAlert){
                    Alert(title: Text("Error with \(loginType.rawValue)"), message: Text(errorMessage), dismissButton: .cancel(Text("Okay")))
                }
            
        }.navigationBarBackButtonHidden(true)
    }
    
    func resetFields(){
        loginType = .login
        
        username = ""
        password = ""
        
        passwordConfirm = ""
        name = ""
        phoneNum = ""
        licensePlate = ""
        
        showAlert = false
        errorTitle = ""
        errorMessage = ""
    }
    
    func validated() -> Bool{
        
        switch loginType{
        case .login:
            guard username != "" && password != ""
            else{
                errorTitle = "Error trying to Log In"
                errorMessage = "Fields must be filled in"
                return false
            }
            
        case .signup:
            guard username != "" && password != "" && passwordConfirm != "" && name != "" && phoneNum != "" && licensePlate != ""
            else{
                errorTitle = "Error trying to Sign Up"
                errorMessage = "Fields must be filled in"
                return false
            }
            
            guard password == passwordConfirm
            else{
                errorTitle = "Error trying to Sign Up"
                errorMessage = "Passwords must match"
                return false
            }
            
            guard licensePlate.count >= 2 && licensePlate.count <= 8
            else{
                errorMessage = "License Plate must be between 2-8 alphanumeric charactors"
                return false
            }
            
            guard phoneNum.count == 10
            else{
                errorMessage = "Phone Number must be 10 digits"
                return false
            }
            
        }
        return true
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
