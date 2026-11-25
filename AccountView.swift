import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var account: AccountStore
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isCreatingAccount = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 1, green: 0.88, blue: 0.91), Color(red: 0.96, green: 0.84, blue: 0.89)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 22) {
                    Text("📔").font(.system(size: 74))
                    VStack(spacing: 6) {
                        Text("Alia Planner").font(.system(size: 32, weight: .bold, design: .rounded))
                        Text(isCreatingAccount ? "Make your planner yours." : "Welcome back to your little space.")
                            .font(.system(size: 16, design: .serif)).foregroundStyle(.secondary)
                    }
                    VStack(spacing: 14) {
                        TextField("Username", text: $username)
                            .textContentType(.username).textInputAutocapitalization(.never).autocorrectionDisabled()
                            .padding().background(.white.opacity(0.85)).clipShape(RoundedRectangle(cornerRadius: 12))
                        SecureField("Password", text: $password)
                            .textContentType(isCreatingAccount ? .newPassword : .password)
                            .padding().background(.white.opacity(0.85)).clipShape(RoundedRectangle(cornerRadius: 12))
                        if isCreatingAccount {
                            SecureField("Confirm password", text: $confirmPassword)
                                .textContentType(.newPassword).padding().background(.white.opacity(0.85)).clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    if let message = account.errorMessage {
                        Text(message).font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundStyle(.red).multilineTextAlignment(.center)
                    }
                    Button {
                        submit()
                    } label: {
                        Text(isCreatingAccount ? "Create my account" : "Sign in")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity).padding(.vertical, 15)
                            .background(Color(red: 0.84, green: 0.29, blue: 0.46)).foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 13))
                    }
                    .buttonStyle(.plain)
                    Button(isCreatingAccount ? "I already have an account" : "Create a new account") {
                        isCreatingAccount.toggle()
                        account.errorMessage = nil
                        password = ""
                        confirmPassword = ""
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.55, green: 0.18, blue: 0.29))
                }
                .padding(28)
            }
        }
    }

    private func submit() {
        if isCreatingAccount {
            guard password == confirmPassword else {
                account.errorMessage = "The passwords do not match."
                return
            }
            _ = account.createAccount(username: username, password: password)
        } else {
            _ = account.signIn(username: username, password: password)
        }
    }
}
