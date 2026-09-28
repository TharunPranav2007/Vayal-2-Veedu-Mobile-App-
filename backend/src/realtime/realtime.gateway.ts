import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: 'ws/orders',
})
export class RealtimeGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  handleConnection(client: Socket) {
    console.log(`⚡ WebSocket client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`🔌 WebSocket client disconnected: ${client.id}`);
  }

  @SubscribeMessage('joinOrderRoom')
  handleJoinOrderRoom(@MessageBody() data: { orderId: string }, @ConnectedSocket() client: Socket) {
    const room = `order:${data.orderId}`;
    client.join(room);
    console.log(`Client ${client.id} joined room ${room}`);
    return { event: 'joinedRoom', data: { room } };
  }

  notifyOrderStatusUpdate(orderId: string, status: string) {
    this.server.to(`order:${orderId}`).emit('orderStatusUpdated', {
      orderId,
      status,
      timestamp: new Date().toISOString(),
    });
  }
}
