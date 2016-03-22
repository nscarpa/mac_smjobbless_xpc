//
//  main.m
//  privileged-helper
//
//  Created by Studio on 22/03/16.
//  Copyright © 2016 Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <xpc/xpc.h>

static const char* helper_name = "it.nicoloscarpa.studio.privileged-helper";

static void __XPC_Peer_Event_Handler(xpc_connection_t connection, xpc_object_t event) {
    xpc_type_t type = xpc_get_type(event);
    
    if (type == XPC_TYPE_ERROR) {
        if (event == XPC_ERROR_CONNECTION_INVALID) {
            
        } else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
            
        }
        
        return;
    }
    
    xpc_connection_t remote = xpc_dictionary_get_remote_connection(event);
    
    xpc_object_t reply = xpc_dictionary_create_reply(event);
    const char* response = "Hi there, host application!";
    xpc_dictionary_set_string(reply, "response", response);
    
    xpc_connection_send_message(remote, reply);
    
    // xpc_release(remote); // not allowed in ARC
}

static void __XPC_Connection_Hanlder(xpc_connection_t connection) {
    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
        __XPC_Peer_Event_Handler(connection, event);
    });
    
    xpc_connection_resume(connection);
}

int main(int argc, const char * argv[]) {
    xpc_connection_t service = xpc_connection_create_mach_service(helper_name, dispatch_get_main_queue(), XPC_CONNECTION_MACH_SERVICE_LISTENER);
    
    if (!service) {
        exit(EXIT_FAILURE);
    }
    
    xpc_connection_set_event_handler(service, ^(xpc_object_t connection) {
        __XPC_Connection_Hanlder(connection);
    });
    
    xpc_connection_resume(service);
    
    dispatch_main();
    
    // xpc_release(service); // not allowed in ARC
    
    return EXIT_SUCCESS;
}
