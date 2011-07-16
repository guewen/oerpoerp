# -*- coding: utf-8 -*-
##############################################################################
#
#    OpenERP, Open Source Management Solution
#    Copyright (C) 2011 Guewen Baconnier
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################

{
    'name': 'Oerpoerp addon (Migration Ruby DSL)',
    'version': '1.0',
    'category': 'Migration Module',
    'description': """
This module is mandatory to use the oerpoerp Ruby Migration DSL.
It creates an object to store the source id to target id references of each resource.
    """,
    'author': 'Guewen Baconnier',
    'website': '',
    'depends': ['base'],
    'init_xml': [],
    'update_xml': [],
    'demo_xml': [],
    'test': [],
    'installable': True,
    'active': False,
}