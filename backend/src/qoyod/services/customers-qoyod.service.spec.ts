import { Logger } from '@nestjs/common';
import { of, throwError } from 'rxjs';
import { CustomersQoyodService } from './customers-qoyod.service';

jest.mock('src/user/user.repository', () => ({ UserRepository: class {} }));

describe('CustomersQoyodService', () => {
  const userId = 'user-1';
  const user = {
    userName: 'Test User',
    phone: '0500000000',
    email: 'test@example.com',
  };

  let httpService: { get: jest.Mock; post: jest.Mock; put: jest.Mock };
  let userRepository: {
    findUserByIdOr404: jest.Mock;
    updateQoyodCustomerId: jest.Mock;
  };
  let service: CustomersQoyodService;

  const qoyodError = (status: number) =>
    throwError(() => ({
      message: `Request failed with status code ${status}`,
      response: { status, data: { message: 'Qoyod error' } },
    }));

  beforeAll(() => {
    Logger.overrideLogger(false);
  });

  beforeEach(() => {
    process.env.QOYOD_API_KEY = 'test-key';

    httpService = {
      get: jest.fn(),
      post: jest.fn(() => of({ data: { contact: { id: 222 } } })),
      put: jest.fn(() => of({ data: { contact: { id: 111 } } })),
    };
    userRepository = {
      findUserByIdOr404: jest.fn(),
      updateQoyodCustomerId: jest.fn(),
    };

    service = new CustomersQoyodService(
      httpService as any,
      userRepository as any,
    );
  });

  describe('ensureCustomerForUser', () => {
    it('creates and saves a customer when the user has none', async () => {
      userRepository.findUserByIdOr404.mockResolvedValue({
        ...user,
        qoyodCustomerId: null,
      });

      await expect(service.ensureCustomerForUser(userId)).resolves.toBe(222);

      expect(httpService.get).not.toHaveBeenCalled();
      expect(httpService.post).toHaveBeenCalledWith(
        expect.stringMatching(/\/customers$/),
        {
          contact: expect.objectContaining({
            name: user.userName,
            phone_number: user.phone,
            email: user.email,
          }),
        },
        expect.anything(),
      );
      expect(userRepository.updateQoyodCustomerId).toHaveBeenCalledWith(
        userId,
        222,
      );
    });

    it('keeps the saved customer when it exists in Qoyod', async () => {
      userRepository.findUserByIdOr404.mockResolvedValue({
        ...user,
        qoyodCustomerId: 111,
      });
      httpService.get.mockReturnValue(of({ data: { contact: { id: 111 } } }));

      await expect(service.ensureCustomerForUser(userId)).resolves.toBe(111);

      expect(httpService.get).toHaveBeenCalledWith(
        expect.stringMatching(/\/customers\/111$/),
        expect.anything(),
      );
      expect(httpService.post).not.toHaveBeenCalled();
      expect(userRepository.updateQoyodCustomerId).not.toHaveBeenCalled();
    });

    it('recreates the customer when Qoyod returns 404', async () => {
      userRepository.findUserByIdOr404.mockResolvedValue({
        ...user,
        qoyodCustomerId: 111,
      });
      httpService.get.mockReturnValue(qoyodError(404));

      await expect(service.ensureCustomerForUser(userId)).resolves.toBe(222);

      expect(httpService.post).toHaveBeenCalledTimes(1);
      expect(userRepository.updateQoyodCustomerId).toHaveBeenCalledWith(
        userId,
        222,
      );
    });

    it('keeps the saved customer when the lookup fails for another reason', async () => {
      userRepository.findUserByIdOr404.mockResolvedValue({
        ...user,
        qoyodCustomerId: 111,
      });
      httpService.get.mockReturnValue(qoyodError(500));

      await expect(service.ensureCustomerForUser(userId)).resolves.toBe(111);

      expect(httpService.post).not.toHaveBeenCalled();
      expect(userRepository.updateQoyodCustomerId).not.toHaveBeenCalled();
    });

    it('does not save anything when Qoyod returns no customer ID', async () => {
      userRepository.findUserByIdOr404.mockResolvedValue({
        ...user,
        qoyodCustomerId: null,
      });
      httpService.post.mockReturnValue(of({ data: {} }));

      await expect(service.ensureCustomerForUser(userId)).rejects.toThrow(
        'Qoyod did not return a customer ID',
      );

      expect(userRepository.updateQoyodCustomerId).not.toHaveBeenCalled();
    });
  });

  describe('updateCustomerFromUser', () => {
    it('creates the customer instead of updating when the user has no ID', async () => {
      userRepository.findUserByIdOr404.mockResolvedValue({
        ...user,
        qoyodCustomerId: null,
      });

      await service.updateCustomerFromUser({
        userId,
        qoyodCustomerId: null,
        userName: user.userName,
        email: user.email,
      });

      expect(httpService.put).not.toHaveBeenCalled();
      expect(httpService.post).toHaveBeenCalledTimes(1);
      expect(userRepository.updateQoyodCustomerId).toHaveBeenCalledWith(
        userId,
        222,
      );
    });

    it('updates the existing customer when the user has an ID', async () => {
      await service.updateCustomerFromUser({
        userId,
        qoyodCustomerId: 111,
        userName: 'New Name',
        email: 'new@example.com',
      });

      expect(httpService.put).toHaveBeenCalledWith(
        expect.stringMatching(/\/customers\/111$/),
        { contact: { name: 'New Name', email: 'new@example.com' } },
        expect.anything(),
      );
      expect(httpService.post).not.toHaveBeenCalled();
      expect(userRepository.updateQoyodCustomerId).not.toHaveBeenCalled();
    });
  });
});
