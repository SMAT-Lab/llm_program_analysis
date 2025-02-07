import {
  INotificationTemplatePayload,
  INotificationTemplates,
} from './notification-template.interface';
import { WithHttp } from '../novu.interface';
export class NotificationTemplates
  extends WithHttp
  implements INotificationTemplates
{
  async getAll(page = 0, limit = 10) {
    return await this.http.get(`/notification-templates`, {
      params: { page, limit },
    });
  }
  async create(data: INotificationTemplatePayload) {
    return await this.http.post(`/notification-templates`, {
      ...data,
    });
  }
  async update(templateId: string, data: INotificationTemplatePayload) {
    return await this.http.put(`/notification-templates/${templateId}`, {
      ...data,
    });
  }
  async delete(templateId: string) {
    return await this.http.delete(`/notification-templates/${templateId}`);
  }
  async getOne(templateId: string) {
    return await this.http.get(`/notification-templates/${templateId}`);
  }
  async updateStatus(templateId: string, active: boolean) {
    return await this.http.put(`/notification-templates/${templateId}/status`, {
      active,
    });
  }
}