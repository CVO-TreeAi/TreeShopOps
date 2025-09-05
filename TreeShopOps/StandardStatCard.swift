import SwiftUI

struct StandardStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
            
            VStack(spacing: 6) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 85)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HStack {
        StandardStatCard(title: "Total", value: "12", icon: "doc.text", color: .gray)
        StandardStatCard(title: "In Progress", value: "5", icon: "gearshape.2", color: .orange)
        StandardStatCard(title: "Completed", value: "7", icon: "checkmark.circle", color: Color("TreeShopGreen"))
    }
    .padding()
    .background(Color("TreeShopBlack"))
}