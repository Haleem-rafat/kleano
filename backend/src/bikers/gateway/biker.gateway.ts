import { Logger, OnModuleInit } from '@nestjs/common';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { AuthService } from '../../auth/auth.service';
import { OrderStatus } from '../../orders/schemas/orders.schema';
import { UsersOrdersService } from '../../orders/services/userOrders.service';
import { UserService } from '../../user/user.service';
import { BikersService } from '../services/bikers.service';
@WebSocketGateway()
export class BikerGateway
  implements OnGatewayConnection, OnGatewayDisconnect, OnModuleInit
{
  constructor(
    private authService: AuthService,
    private usersOrdersService: UsersOrdersService,
    private userService: UserService,
    private bikersService: BikersService,
  ) {}

  @WebSocketServer()
  server: Server;

  private logger: Logger = new Logger('Biker Gateway');

  onModuleInit() {
    this.logger.log('Biker WebSocket Initialized ...');
  }
  handleDisconnect(socket: Socket) {
    socket.disconnect();
  }
  async handleConnection(socket: Socket, ...args: any[]) {
    const userPayload = this.authService.authenticateSocketUser(socket);
    if (!userPayload?.id) return;

    const user = await this.authService.getUserByIdAndRole(
      userPayload.id,
      userPayload.role,
    );
    if (user) {
      // Inject user into socket
      socket.data.user = user;
      // Update SocketId
      await this.authService.updateUserSocketId(
        userPayload.id,
        userPayload.role,
        socket.id,
      );
    } else {
      this.disconnect(socket);
    }
  }
  private disconnect(socket: Socket) {
    socket.disconnect();
  }

  @SubscribeMessage('biker:location-changes')
  async bikerLocationChangesListener(
    @MessageBody() body: any,
    @ConnectedSocket() socket: Socket,
  ) {
    // Get Order for trackerUser
    const order = await this.usersOrdersService.getOrderByQuery({
      _id: body.order,
      biker: socket.data.user._id,
      status: OrderStatus.BIKER_ON_THE_WAY,
    });
    //  Handle order not Existing
    if (order) {
      // Update biker location on DB
      await this.bikersService.updateBikerLocation(
        socket.data.user._id.toString(),
        {
          latitude: Number(body.latitude),
          longitude: Number(body.longitude),
          streetName: body.streetName,
          subAdministrativeArea: body.subAdministrativeArea,
        },
      );

      const listenerUser = await this.userService.getUser(
        order.user.toString(),
      );

      // emit to this socket bikerLocation
      this.server.to(listenerUser.socketId).emit('biker:move', body);
    }
  }
}
