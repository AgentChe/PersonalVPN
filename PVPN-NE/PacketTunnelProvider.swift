import NetworkExtension
import TunnelKit

class PacketTunnelProvider: OpenVPNTunnelProvider {
    override init() {
        super.init()
        dataCountInterval = 1000
    }
}
