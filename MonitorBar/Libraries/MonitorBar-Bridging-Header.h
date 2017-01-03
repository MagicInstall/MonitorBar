//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <IOKit/IOTypes.h>
#import "smc.h"
#import "CHelper.h"
#import "SMCValue.h"
#import "Sensor.h"
#import "NetworkSensor.h"
#import "StorageSensor.h"
#import "CPUSensor.h"
#import "MemorySensor.h"
#import "HistoryValues.h"



// MARK: -
// MARK: smc
kern_return_t SMCOpen(const char *serviceName, io_connect_t *conn);
kern_return_t SMCClose(io_connect_t conn);
kern_return_t SMCReadKey(io_connect_t conn, const UInt32Char_t key, SMCVal_t *val);
kern_return_t SMCCall(io_connect_t conn, int index, SMCKeyData_t *inputStructure, SMCKeyData_t *outputStructure);


