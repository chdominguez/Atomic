// MolReader extension to load GAMESS and Gaussian LOG files.

import SceneKit

extension MolReader {
    
    func readLOG(data: String) -> [Step]? {
        var logSoftware: compSoftware = .gaussian
        
        //First check .log type. Gaussian or GAMESS
        for software in compSoftware.allCases {
            if data.contains(software.rawValue) {
                logSoftware = software
            }
        }
    
        //Read specifically one of the softwares
        switch logSoftware {
        case .gaussian:
            //guard let steps = readGaussianlog(lines: separatedData) else {return nil}
            return nil
        case .gamess:
            //guard let steps = readGAMESSlog(lines: separatedData) else {return nil}
            return nil
        }
        
    }
    
}
