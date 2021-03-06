//
//  AMQPChannel.m
//  Objective-C wrapper for librabbitmq-c
//
//  Copyright 2009 Max Wolter. All rights reserved.
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "AMQP+Private.h"
#import "AMQPError.h"
#import "AMQPConnection+Private.h"

@interface AMQPChannel ()

@property (strong, readwrite) AMQPConnection *connection;

@end

@implementation AMQPChannel

- (instancetype)init
{
    if ((self = [super init])) {
		_internalChannel = 0;
	}
	
	return self;
}

- (void)dealloc
{
    [self close];
}

- (NSError *)openChannel:(amqp_channel_t)channel onConnection:(AMQPConnection *)connection
{
	_connection = (id)connection;
	_internalChannel = channel;

	amqp_channel_open_ok_t *result = amqp_channel_open(((AMQPConnection *)_connection).internalConnection, _internalChannel);
    if (!result) {
        amqp_rpc_reply_t reply = amqp_get_rpc_reply(self.connection.internalConnection);
        // TODO: fix error
        return [AMQPError errorWithCode:AMQPErrorCodeServerError reply_t:reply];
    }

    return nil;
}

- (void)close
{
    if (0 != _internalChannel) {
        amqp_rpc_reply_t reply = amqp_channel_close(((AMQPConnection *)_connection).internalConnection, _internalChannel, AMQP_REPLY_SUCCESS);
        if (reply.reply_type == AMQP_RESPONSE_NORMAL) {
            _internalChannel = 0;
        }
    }
}

@end
