import type { AbilityBuilder } from '@casl/ability'

import type { AppAbility } from '.'
import type { User } from './models/user'
import type { Role } from './roles'

type PermissionsByRole = (
  user: User,
  builder: AbilityBuilder<AppAbility>,
) => void

export const permissions: Record<Role, PermissionsByRole> = {
  ADMIN: (user, { can, cannot }) => {
    can('manage', 'all')

    /* 
        To give permission to an admin that already has the "manage all" ability
        but restrict some actions, we need to explicitly define the restrictions, so we
        use the `cannot` method to deny the entire action first, then we use `can` to allow it
        only for specific conditions. For example, here we deny the `transfer_ownership` action
        on the `Organization` subject for admins, but then we allow it only if the admin
        is the owner of the organization. 
    */
    cannot(['transfer_ownership', 'update'], 'Organization')
    can(['transfer_ownership', 'update'], 'Organization', {
      ownerId: { $eq: user.id },
    })
  },
  MEMBER: (user, { can }) => {
    can('get', 'User')
    can(['create', 'get'], 'Project')
    can(['update', 'delete'], 'Project', { ownerId: { $eq: user.id } })
  },
  BILLING: (_, { can }) => {
    can('manage', 'Billing')
  },
}
