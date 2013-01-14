/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

package com.liferay.portlet.expando.service.impl;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.security.permission.ActionKeys;
import com.liferay.portlet.expando.model.ExpandoColumn;
import com.liferay.portlet.expando.model.ExpandoValue;
import com.liferay.portlet.expando.service.base.ExpandoValueServiceBaseImpl;
import com.liferay.portlet.expando.service.permission.ExpandoColumnPermissionUtil;

import java.io.Serializable;

import java.util.Collection;
import java.util.Map;

/**
 * @author Brian Wing Shun Chan
 */
public class ExpandoValueServiceImpl extends ExpandoValueServiceBaseImpl {

	public ExpandoValue addValue(
			long companyId, String className, String tableName,
			String columnName, long classPK, Object data)
		throws PortalException, SystemException {

		ExpandoColumn column = expandoColumnLocalService.getColumn(
			companyId, className, tableName, columnName);

		ExpandoColumnPermissionUtil.check(
			getPermissionChecker(), column, ActionKeys.UPDATE);

		return expandoValueLocalService.addValue(
			companyId, className, tableName, columnName, classPK, data);
	}

	public ExpandoValue addValue(
			long companyId, String className, String tableName,
			String columnName, long classPK, String data)
		throws PortalException, SystemException {

		ExpandoColumn column = expandoColumnLocalService.getColumn(
			companyId, className, tableName, columnName);

		ExpandoColumnPermissionUtil.check(
			getPermissionChecker(), column, ActionKeys.UPDATE);

		return expandoValueLocalService.addValue(
			companyId, className, tableName, columnName, classPK, data);
	}

	public void addValues(
			long companyId, String className, String tableName, long classPK,
			Map<String, Serializable> attributeValues)
		throws PortalException, SystemException {

		for (Map.Entry<String, Serializable> entry :
				attributeValues.entrySet()) {

			addValue(
				companyId, className, tableName, entry.getKey(), classPK,
				entry.getValue());
		}
	}

	public Map<String, Serializable> getData(
			long companyId, String className, String tableName,
			Collection<String> columnNames, long classPK)
		throws PortalException, SystemException {

		Map<String, Serializable> attributeValues =
			expandoValueLocalService.getData(
				companyId, className, tableName, columnNames, classPK);

		for (String columnName : columnNames) {
			ExpandoColumn column = expandoColumnLocalService.getColumn(
				companyId, className, tableName, columnName);

			if (!ExpandoColumnPermissionUtil.contains(
					getPermissionChecker(), column, ActionKeys.VIEW)) {

				attributeValues.remove(columnName);
			}
		}

		return attributeValues;
	}

	public Serializable getData(
			long companyId, String className, String tableName,
			String columnName, long classPK)
		throws PortalException, SystemException {

		ExpandoColumn column = expandoColumnLocalService.getColumn(
			companyId, className, tableName, columnName);

		if (ExpandoColumnPermissionUtil.contains(
				getPermissionChecker(), column, ActionKeys.VIEW)) {

			return expandoValueLocalService.getData(
				companyId, className, tableName, columnName, classPK);
		}
		else {
			return null;
		}
	}

	public JSONObject getJSONData(
			long companyId, String className, String tableName,
			String columnName, long classPK)
		throws PortalException, SystemException {

		ExpandoColumn column = expandoColumnLocalService.getColumn(
			companyId, className, tableName, columnName);

		if (column!=null && ExpandoColumnPermissionUtil.contains(	/* LPS-32264 */
				getPermissionChecker(), column, ActionKeys.VIEW)) {

			ExpandoValue value=expandoValueLocalService.getValue(
					companyId, className, tableName, columnName, classPK); /* LPS-32264 */
			if(value==null){
				return JSONFactoryUtil.createJSONObject( JSONFactoryUtil.getNullJSON()); /* LPS-32264 */
			}
			
			String data=""; /* LPS-32264 */
			switch(column.getType()){ /* LPS-32264 */
				case ExpandoColumnConstants.BOOLEAN:
				case ExpandoColumnConstants.DATE:
				case ExpandoColumnConstants.DOUBLE:
				case ExpandoColumnConstants.FLOAT:
				case ExpandoColumnConstants.INTEGER:
				case ExpandoColumnConstants.LONG:
				case ExpandoColumnConstants.NUMBER:
				case ExpandoColumnConstants.SHORT:
				case ExpandoColumnConstants.STRING:
					data=value.getData();	
					if (Validator.isNotNull(data)) { 
						if (!data.startsWith(StringPool.OPEN_CURLY_BRACE)) {
							data = "\""+data+"\"";
						}
					}
					break;
				case ExpandoColumnConstants.BOOLEAN_ARRAY:
					boolean[] bdata=value.getBooleanArray();
					String bvdata="";
					for(boolean b:bdata){
						bvdata+=",{value:"+"\""+Boolean.toString(b)+"\"}";
					}
					if(bvdata.length()>0){
						bvdata=bvdata.substring(1);
					}
					data+="["+bvdata+ "]";
					break;
				case ExpandoColumnConstants.DATE_ARRAY:
					Date[] adata=value.getDateArray();
					String avdata="";
					for(Date b:adata){
						avdata+=",{value:"+"\""+Long.toString(b.getTime())+"\"}";
					}
					if(avdata.length()>0){
						avdata=avdata.substring(1);
					}
					data+="["+avdata+ "]";
					break;
				case ExpandoColumnConstants.DOUBLE_ARRAY:
					double[] ddata=value.getDoubleArray();
					String dvdata="";
					for(double b:ddata){
						dvdata+=",{value:"+"\""+Double.toString(b)+"\"}";
					}
					if(dvdata.length()>0){
						dvdata=dvdata.substring(1);
					}
					data+="["+dvdata+ "]";
					break;
				case ExpandoColumnConstants.FLOAT_ARRAY:
					float[] fdata=value.getFloatArray();
					String fvdata="";
					for(float b:fdata){
						fvdata+=",{value:"+"\""+Float.toString(b)+"\"}";
					}
					if(fvdata.length()>0){
						fvdata=fvdata.substring(1);
					}
					data+="["+fvdata+ "]";
					break;
				case ExpandoColumnConstants.INTEGER_ARRAY:
					int[] idata=value.getIntegerArray();
					String ivdata="";
					for(int b:idata){
						ivdata+=",{value:"+"\""+Integer.toString(b)+"\"}";
					}
					if(ivdata.length()>0){
						ivdata=ivdata.substring(1);
					}
					data+="["+ivdata+ "]";
					break;
				case ExpandoColumnConstants.LONG_ARRAY:
					long[] ldata=value.getLongArray();
					String lvdata="";
					for(long b:ldata){
						lvdata+=",{value:"+"\""+Long.toString(b)  +"\"}";
					}
					if(lvdata.length()>0){
						lvdata=lvdata.substring(1);
					}
					data+="["+lvdata+ "]";
					break;
				case ExpandoColumnConstants.NUMBER_ARRAY:
					Number[] ndata=value.getNumberArray();
					String nvdata="";
					for(Number b:ndata){
						nvdata+=",{value:"+"\""+ b.toString() +"\"}";
					}
					if(nvdata.length()>0){
						nvdata=nvdata.substring(1);
					}
					data+="["+nvdata+ "]";
					break;
				case ExpandoColumnConstants.SHORT_ARRAY:
					short[] odata=value.getShortArray();
					String ovdata="";
					for(short b:odata){
						ovdata+=",{value:"+"\""+Short.toString(b) +"\"}";
					}
					if(ovdata.length()>0){
						ovdata=ovdata.substring(1);
					}
					data+="["+ovdata+ "]";
					break;
				case ExpandoColumnConstants.STRING_ARRAY:
					String[] sdata=value.getStringArray();
					String svdata="";
					for(String b:sdata){
						svdata+=",{value:"+"\""+ b+"\"}";
					}
					if(svdata.length()>0){
						svdata=svdata.substring(1);
					}
					data+="["+svdata+ "]";
					break;
			}

			if (Validator.isNotNull(data)) { 
				if (!data.startsWith(StringPool.OPEN_CURLY_BRACE)) {
					data = "{data:"+data+"}";	/* LPS-32264 */
				}

				return JSONFactoryUtil.createJSONObject(data);
			}
			else {
				return JSONFactoryUtil.createJSONObject( JSONFactoryUtil.getNullJSON()); /* LPS-32264 */
			}
		}
		else {
			return JSONFactoryUtil.createJSONObject( JSONFactoryUtil.getNullJSON()); /* LPS-32264 */
		}
	}

}
